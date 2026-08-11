"""Build an annual Bing/Ookla-quadkey population crosswalk for Syria from WorldPop.

Source:  WorldPop constrained global mosaic, Syria, one raster per year
         2015-2030 (R2025A), 100m.
         https://hub.worldpop.org/geodata/listing?id=135

For every populated pixel in each year's raster, this script maps the pixel
centroid to the zoom-16 quadkey used by the Ookla tiles (same verification
as before: matches the `tile_x`/`tile_y` columns present in Ookla files from
Q3 2023 onward), then sums population per quadkey. It covers the full Syria
raster, not just quadkeys with observed Ookla activity, so the output can
serve as a population denominator for coverage metrics.

Usage:
    uv run build_population_crosswalk.py                  # years 2019-2025 (Ookla panel range)
    uv run build_population_crosswalk.py --years 2019 2020 2021  # a specific subset
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path

import numpy as np
import pandas as pd
import rasterio
import rasterio.transform
import requests

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
log = logging.getLogger("population_crosswalk")

WORLDPOP_URL_TEMPLATE = (
    "https://data.worldpop.org/GIS/Population/Global_2015_2030/R2025A/{year}/SYR/"
    "v1/100m/constrained/syr_pop_{year}_CN_100m_R2025A_v1.tif"
)
RASTER_DIR = Path("data/syria-nowcasting/raw/population")
OUTPUT_PATH = Path("data/syria-nowcasting/processed/quadkey_population_annual.parquet")
QUADKEY_ZOOM = 16  # matches the Ookla tile zoom level
DEFAULT_YEARS = list(range(2019, 2026))  # Ookla panel range at time of writing


def download_raster(year: int) -> Path:
    dest = RASTER_DIR / f"syr_pop_{year}_CN_100m_R2025A_v1.tif"
    if dest.exists():
        log.info(f"[skip] {dest} already exists")
        return dest
    url = WORLDPOP_URL_TEMPLATE.format(year=year)
    log.info(f"Downloading {url} ...")
    dest.parent.mkdir(parents=True, exist_ok=True)
    with requests.get(url, stream=True, timeout=120) as r:
        r.raise_for_status()
        with open(dest, "wb") as f:
            for chunk in r.iter_content(chunk_size=1 << 20):
                f.write(chunk)
    log.info(f"Saved -> {dest}")
    return dest


def lonlat_to_quadkey_int(
    lon: np.ndarray, lat: np.ndarray, zoom: int = QUADKEY_ZOOM
) -> np.ndarray:
    """Vectorized Bing tile-system quadkey, returned as its base-4 integer value.

    Zero-padding this integer's base-4 representation to `zoom` digits gives
    the quadkey string used by the Ookla tiles.
    """
    n = 1 << zoom
    lat_rad = np.radians(lat)
    x = np.clip(((lon + 180.0) / 360.0 * n).astype(np.int64), 0, n - 1)
    y = np.clip(
        (
            (1.0 - np.log(np.tan(lat_rad) + 1.0 / np.cos(lat_rad)) / np.pi) / 2.0 * n
        ).astype(np.int64),
        0,
        n - 1,
    )

    def spread(v: np.ndarray) -> np.ndarray:
        # Interleaves bit i of v into bit 2i, leaving odd bits free for the
        # other axis (a 2D Morton/Z-order code).
        v = v.astype(np.uint64)
        out = np.zeros_like(v)
        for i in range(zoom):
            out |= ((v >> i) & 1) << (2 * i)
        return out

    return spread(x) | (spread(y) << 1)


def quadkey_int_to_str(values: np.ndarray, zoom: int = QUADKEY_ZOOM) -> np.ndarray:
    digits = []
    for i in range(zoom):
        shift = 2 * (zoom - 1 - i)
        digits.append(((values >> shift) & 3).astype(str))
    out = digits[0]
    for d in digits[1:]:
        out = np.char.add(out, d)
    return out


def build_crosswalk_for_year(raster_path: Path, year: int) -> pd.DataFrame:
    """Sum population per quadkey for one year, streaming the raster block by block."""
    totals: dict[str, float] = {}
    with rasterio.open(raster_path) as src:
        nodata = src.nodata
        for _, window in src.block_windows(1):
            block = src.read(1, window=window)
            valid = ~np.isnan(block) & (block > 0)
            if nodata is not None:
                valid &= block != nodata
            if not valid.any():
                continue

            rows, cols = np.nonzero(valid)
            pops = block[rows, cols].astype(np.float64)
            xs, ys = rasterio.transform.xy(
                src.window_transform(window), rows, cols, offset="center"
            )
            quadkeys = quadkey_int_to_str(
                lonlat_to_quadkey_int(np.asarray(xs), np.asarray(ys))
            )

            block_totals = pd.Series(pops).groupby(quadkeys).sum()
            for quadkey, total in block_totals.items():
                totals[quadkey] = totals.get(quadkey, 0.0) + total

    crosswalk = (
        pd.Series(totals, name="population")
        .rename_axis("quadkey")
        .reset_index()
        .sort_values("quadkey")
        .reset_index(drop=True)
    )
    crosswalk["population"] = crosswalk["population"].round(1)
    crosswalk.insert(0, "year", year)
    return crosswalk


def main(years: list[int]) -> None:
    frames = []
    for year in years:
        raster_path = download_raster(year)
        log.info(f"Aggregating {year} population to quadkeys...")
        year_crosswalk = build_crosswalk_for_year(raster_path, year)
        log.info(
            f"{year}: {len(year_crosswalk):,} quadkeys, "
            f"total population {year_crosswalk['population'].sum():,.0f}"
        )
        frames.append(year_crosswalk)

    crosswalk = pd.concat(frames, ignore_index=True)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    crosswalk.to_parquet(OUTPUT_PATH, index=False)
    log.info(f"Saved {len(crosswalk):,} year-quadkey rows -> {OUTPUT_PATH}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--years",
        nargs="+",
        type=int,
        default=DEFAULT_YEARS,
        help="years to fetch, e.g. --years 2019 2020 2021",
    )
    args = parser.parse_args()
    main(args.years)
