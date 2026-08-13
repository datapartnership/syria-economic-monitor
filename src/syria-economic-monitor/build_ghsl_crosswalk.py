"""Build a GHSL degree-of-urbanisation crosswalk for Syria's Ookla quadkey grid.

Source:  JRC GHSL GHS-SMOD (Global Human Settlement Layer, Settlement Model
         grid), epoch 2020, release R2023A, 30 arcsec (~1km) EPSG:4326 variant.
         https://human-settlement.emergency.copernicus.eu/ghs_smod2023.php

GHS-SMOD is only produced at ~1km resolution — coarser than a zoom-16 Ookla
quadkey (~600m x ~490m at Syria's latitude). This is a *sample-at-centroid* operation:
each quadkey's centroid lon/lat is computed by inverting the same quadkey math the
population script uses to go the other way, and the single SMOD class covering that point
is looked up directly. A 1km class stamped onto a <1km tile will misclassify some
urban-edge tiles.

Usage:
    uv run build_ghsl_crosswalk.py
"""

from __future__ import annotations

import logging
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd
import rasterio

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
log = logging.getLogger("ghsl_crosswalk")

GHSL_URL = (
    "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/"
    "GHS_SMOD_GLOBE_R2023A/GHS_SMOD_E2020_GLOBE_R2023A_4326_30ss/V2-0/"
    "GHS_SMOD_E2020_GLOBE_R2023A_4326_30ss_V2_0.zip"
)
ZIP_PATH = Path(
    "data/syria-nowcasting/raw/ghsl/GHS_SMOD_E2020_GLOBE_R2023A_4326_30ss_V2_0.zip"
)
RASTER_PATH = Path(
    "data/syria-nowcasting/raw/ghsl/GHS_SMOD_E2020_GLOBE_R2023A_4326_30ss_V2_0.tif"
)
POP_PATH = Path("data/syria-nowcasting/processed/quadkey_population_annual.parquet")
OUTPUT_PATH = Path("data/syria-nowcasting/processed/quadkey_urbanization.parquet")
QUADKEY_ZOOM = 16

# GHS-SMOD class codes (GHSL "Degree of Urbanisation" Level 2 legend).
SMOD_LABELS = {
    30: "Urban centre",
    23: "Dense urban cluster",
    22: "Semi-dense urban cluster",
    21: "Suburban / peri-urban",
    13: "Rural cluster",
    12: "Low-density rural",
    11: "Very low-density rural",
    10: "Water",
}
URBAN_CLASSES = {30, 23, 22, 21}
RURAL_CLASSES = {13, 12, 11}
WATER_CLASS = 10


def download_raster() -> None:
    if RASTER_PATH.exists():
        log.info(f"[skip] {RASTER_PATH} already exists")
        return
    if not ZIP_PATH.exists():
        import requests

        log.info(f"Downloading {GHSL_URL} ...")
        ZIP_PATH.parent.mkdir(parents=True, exist_ok=True)
        with requests.get(GHSL_URL, stream=True, timeout=120) as r:
            r.raise_for_status()
            with open(ZIP_PATH, "wb") as f:
                for chunk in r.iter_content(chunk_size=1 << 20):
                    f.write(chunk)
        log.info(f"Saved -> {ZIP_PATH}")

    log.info(f"Extracting {RASTER_PATH.name} from zip...")
    with zipfile.ZipFile(ZIP_PATH) as zf:
        tif_names = [n for n in zf.namelist() if n.endswith(".tif")]
        if not tif_names:
            raise FileNotFoundError(f"No .tif found in {ZIP_PATH}")
        with zf.open(tif_names[0]) as src, open(RASTER_PATH, "wb") as dst:
            dst.write(src.read())
    log.info(f"Saved -> {RASTER_PATH}")


def quadkey_to_lonlat(
    quadkeys: np.ndarray, zoom: int = QUADKEY_ZOOM
) -> tuple[np.ndarray, np.ndarray]:
    """Invert the quadkey Morton code back to tile centroid lon/lat.

    Inverse of the `lonlat_to_quadkey_int` / `quadkey_int_to_str` pair in
    `build_population_crosswalk.py`: each base-4 digit's low bit is the tile
    x-bit, high bit is the tile y-bit, read most-significant digit first.
    """
    n_tiles = 1 << zoom
    x = np.zeros(len(quadkeys), dtype=np.int64)
    y = np.zeros(len(quadkeys), dtype=np.int64)
    digits = np.array([[int(c) for c in qk] for qk in quadkeys], dtype=np.int64)
    for i in range(zoom):
        bit_pos = zoom - 1 - i
        x |= (digits[:, i] & 1) << bit_pos
        y |= ((digits[:, i] >> 1) & 1) << bit_pos

    lon = (x + 0.5) / n_tiles * 360.0 - 180.0
    lat_rad = np.arctan(np.sinh(np.pi * (1 - 2 * (y + 0.5) / n_tiles)))
    lat = np.degrees(lat_rad)
    return lon, lat


def build_crosswalk() -> pd.DataFrame:
    quadkey_population = pd.read_parquet(POP_PATH, columns=["quadkey"])
    quadkeys = (
        quadkey_population["quadkey"].drop_duplicates().to_numpy()
    )  # union across years
    log.info(f"Sampling GHS-SMOD at {len(quadkeys):,} quadkey centroids...")

    lon, lat = quadkey_to_lonlat(quadkeys)

    with rasterio.open(RASTER_PATH) as src:
        nodata = src.nodata
        samples = np.fromiter(
            (val[0] for val in src.sample(zip(lon, lat))),
            dtype=np.int32,
            count=len(quadkeys),
        )

    crosswalk = pd.DataFrame({"quadkey": quadkeys, "smod_class": samples})
    if nodata is not None:
        crosswalk.loc[crosswalk["smod_class"] == nodata, "smod_class"] = np.nan

    crosswalk["smod_label"] = crosswalk["smod_class"].map(SMOD_LABELS)
    crosswalk["urbanization"] = np.select(
        [
            crosswalk["smod_class"].isin(URBAN_CLASSES),
            crosswalk["smod_class"].isin(RURAL_CLASSES),
            crosswalk["smod_class"] == WATER_CLASS,
        ],
        ["urban", "rural", "water"],
        default="unclassified",
    )
    return crosswalk


def main() -> None:
    download_raster()
    crosswalk = build_crosswalk()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    crosswalk.to_parquet(OUTPUT_PATH, index=False)
    log.info(f"Saved {len(crosswalk):,} quadkeys -> {OUTPUT_PATH}")
    log.info(f"Urbanization breakdown:\n{crosswalk['urbanization'].value_counts()}")


if __name__ == "__main__":
    main()
