"""Download Ookla Open Data quarterly speed-test tiles, clipped to Syria.

Source:  https://github.com/teamookla/ookla-open-data

For each quarter from Q1 2019 through the current quarter, streams the global
"mobile" and "fixed" performance parquet files directly from Ookla's public S3 bucket.
Then use DuckDB's spatial extension to keep only tiles that intersect Syria's national
boundary.

Usage:
    uv run download_ookla.py                  # all quarters through the current one
    uv run download_ookla.py --end 2024 4     # ... through a specific quarter instead
"""

from __future__ import annotations

import argparse
import datetime as dt
import logging
from pathlib import Path

import duckdb
import geopandas as gpd

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
log = logging.getLogger("ookla_syria")

BASE_URL = "https://ookla-open-data.s3.amazonaws.com/parquet/performance"
SERVICE_TYPES = ("mobile", "fixed")
FIRST_YEAR, FIRST_QUARTER = 2019, 1
QUARTER_START_MONTH = {1: "01", 2: "04", 3: "07", 4: "10"}

# Same ADM0 boundary used across the rest of the project (e.g. the
# internet-connectivity and ntl-analysis notebooks), so Ookla tiles are
# clipped consistently with every other Syria analysis in this repo.
BOUNDARY_PATH = Path("data/boundaries/syr_admin0.shp")
OUTPUT_DIR = Path("data/syria-nowcasting/raw")


def current_quarter() -> tuple[int, int]:
    today = dt.date.today()
    return today.year, (today.month - 1) // 3 + 1


def quarters_through(end_year: int, end_quarter: int):
    year, quarter = FIRST_YEAR, FIRST_QUARTER
    while (year, quarter) <= (end_year, end_quarter):
        yield year, quarter
        quarter += 1
        if quarter > 4:
            quarter = 1
            year += 1


def fetch_syria_boundary() -> str:
    """Return Syria's ADM0 boundary as one WKT (multi)polygon in EPSG:4326.

    Reads the project's canonical Syria ADM0 shapefile (same file used by
    every other Syria analysis in this repo) rather than pulling a
    differently-sourced boundary, so Ookla tile clipping stays consistent
    with the rest of the project's Syria-clipped outputs.
    """
    if not BOUNDARY_PATH.exists():
        raise FileNotFoundError(
            f"{BOUNDARY_PATH} not found — this is the project's shared Syria "
            "ADM0 boundary, expected to already be checked into data/boundaries/"
        )
    gdf = gpd.read_file(BOUNDARY_PATH)
    if gdf.crs is not None and gdf.crs.to_epsg() != 4326:
        gdf = gdf.to_crs(epsg=4326)
    boundary = gdf.union_all()
    return boundary.wkt


def parquet_url(service_type: str, year: int, quarter: int) -> str:
    month = QUARTER_START_MONTH[quarter]
    return (
        f"{BASE_URL}/type={service_type}/year={year}/quarter={quarter}/"
        f"{year}-{month}-01_performance_{service_type}_tiles.parquet"
    )


def output_path(service_type: str, year: int, quarter: int) -> Path:
    out_dir = OUTPUT_DIR / service_type
    out_dir.mkdir(parents=True, exist_ok=True)
    return out_dir / f"{year}_q{quarter}_syria.parquet"


def download_quarter(
    con: duckdb.DuckDBPyConnection,
    service_type: str,
    year: int,
    quarter: int,
    syria_wkt: str,
) -> None:
    dest = output_path(service_type, year, quarter)
    if dest.exists():
        log.info(f"[skip] {dest} already exists")
        return

    url = parquet_url(service_type, year, quarter)
    query = f"""
        COPY (
            SELECT * EXCLUDE (geom)
            FROM (
                SELECT *, ST_GeomFromText(tile) AS geom
                FROM read_parquet('{url}')
            )
            WHERE ST_Intersects(geom, ST_GeomFromText('{syria_wkt}'))
        ) TO '{dest.as_posix()}' (FORMAT PARQUET);
    """
    try:
        con.execute(query)
    except duckdb.Error as exc:
        if "404" in str(exc) or "HTTP Error" in str(exc):
            log.warning(
                f"{year} Q{quarter} {service_type}: not published yet, skipping"
            )
        else:
            log.error(f"{year} Q{quarter} {service_type}: failed — {exc}")
        return

    rows = con.execute(
        f"SELECT COUNT(*) FROM read_parquet('{dest.as_posix()}')"
    ).fetchone()[0]
    if rows == 0:
        # Written deliberately (not skipped) so downstream code can tell
        # "checked, zero tiles" apart from "never ran for this quarter".
        log.warning(
            f"{year} Q{quarter} {service_type}: 0 tiles matched Syria's boundary"
        )
    else:
        log.info(f"{year} Q{quarter} {service_type}: {rows} tiles -> {dest}")


def main(end_year: int | None = None, end_quarter: int | None = None) -> None:
    if end_year is None or end_quarter is None:
        end_year, end_quarter = current_quarter()

    syria_wkt = fetch_syria_boundary()

    con = duckdb.connect()
    con.execute("INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial;")
    con.execute("SET enable_progress_bar = false;")

    for year, quarter in quarters_through(end_year, end_quarter):
        for service_type in SERVICE_TYPES:
            download_quarter(con, service_type, year, quarter, syria_wkt)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--end",
        nargs=2,
        type=int,
        metavar=("YEAR", "QUARTER"),
        help="last quarter to fetch, e.g. --end 2024 4",
    )
    args = parser.parse_args()
    end_year, end_quarter = args.end if args.end else (None, None)
    main(end_year, end_quarter)
