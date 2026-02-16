"""
CHIRPS Rainfall Data Extraction Script for Myanmar

This script downloads CHIRPS rainfall data from Google Earth Engine
and aggregates it by Myanmar administrative regions.

Usage:
    python chirps_data_extraction.py
"""

import ee
import pandas as pd
import geopandas as gpd
from pathlib import Path
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def authenticate_gee(service_account_file=None):
    """
    Authenticate and initialize Google Earth Engine.

    Parameters:
    -----------
    service_account_file : str, optional
        Path to service account JSON file
    """
    try:
        if service_account_file:
            # Use service account authentication
            logger.info(f"Authenticating with service account: {service_account_file}")
            credentials = ee.ServiceAccountCredentials(None, service_account_file)
            ee.Initialize(credentials)
            logger.info("Google Earth Engine initialized with service account")
        else:
            ee.Initialize()
            logger.info("Google Earth Engine already initialized")
    except Exception as e:
        if service_account_file:
            logger.error(f"Failed to initialize with service account: {e}")
            raise
        else:
            logger.info("Authenticating Google Earth Engine with user credentials...")
            ee.Authenticate()
            ee.Initialize()
            logger.info("Google Earth Engine authenticated and initialized")


def get_chirps_rainfall_by_region(
    start_date,
    end_date,
    regions_gdf,
    admin_column="ADM1_EN",
    temporal_resolution="monthly",
    output_dir="../data/rainfall",
):
    """
    Extract CHIRPS rainfall data by administrative regions.

    Parameters:
    -----------
    start_date : str
        Start date (format: 'YYYY-MM-DD')
    end_date : str
        End date (format: 'YYYY-MM-DD')
    regions_gdf : geopandas.GeoDataFrame
        GeoDataFrame containing administrative regions
    admin_column : str
        Column name containing region names
    temporal_resolution : str
        'daily' or 'monthly'
    output_dir : str
        Directory to save output CSV

    Returns:
    --------
    pandas.DataFrame
        DataFrame with columns: region, date, rainfall_mm
    """
    logger.info(f"Extracting CHIRPS rainfall from {start_date} to {end_date}")
    logger.info(f"Temporal resolution: {temporal_resolution}")
    logger.info(f"Number of regions: {len(regions_gdf)}")

    # Ensure CRS is WGS84
    if regions_gdf.crs is None:
        regions_gdf = regions_gdf.set_crs("EPSG:4326")
    elif regions_gdf.crs != "EPSG:4326":
        regions_gdf = regions_gdf.to_crs("EPSG:4326")

    # Myanmar bounding box
    myanmar_bbox = ee.Geometry.Rectangle([92.2, 9.5, 101.2, 28.5])

    # Load CHIRPS dataset
    chirps = (
        ee.ImageCollection("UCSB-CHG/CHIRPS/DAILY")
        .filterDate(start_date, end_date)
        .filterBounds(myanmar_bbox)
    )

    if temporal_resolution == "monthly":
        logger.info("Aggregating to monthly resolution...")

        # Function to create monthly sums
        def monthly_sum(date):
            date = ee.Date(date)
            monthly = chirps.filterDate(date, date.advance(1, "month")).sum()
            return monthly.set("system:time_start", date.millis())

        # Get list of monthly dates
        start = ee.Date(start_date)
        end = ee.Date(end_date)
        months = end.difference(start, "month").round()
        monthly_dates = ee.List.sequence(0, months.subtract(1)).map(
            lambda m: start.advance(m, "month")
        )

        chirps = ee.ImageCollection.fromImages(monthly_dates.map(monthly_sum))

    # Extract for each region
    all_results = []

    for idx, region in regions_gdf.iterrows():
        region_name = region[admin_column]
        logger.info(f"Processing region {idx + 1}/{len(regions_gdf)}: {region_name}")

        # Convert geometry to GEE format
        geom_json = region.geometry.__geo_interface__
        ee_geom = ee.Geometry(geom_json)

        # Extract rainfall for this region
        def extract_regional_rainfall(image):
            stats = image.reduceRegion(
                reducer=ee.Reducer.mean(),
                geometry=ee_geom,
                scale=5000,  # 5km resolution
                maxPixels=1e9,
            )

            return ee.Feature(
                None,
                {
                    "date": image.date().format("YYYY-MM-dd"),
                    "rainfall_mm": stats.get("precipitation"),
                    "region": region_name,
                },
            )

        features = chirps.map(extract_regional_rainfall)

        try:
            data = features.getInfo()

            # Add to results
            for feature in data["features"]:
                props = feature["properties"]
                if props["rainfall_mm"] is not None:
                    all_results.append(
                        {
                            "region": props["region"],
                            "date": pd.to_datetime(props["date"]),
                            "rainfall_mm": props["rainfall_mm"],
                        }
                    )
        except Exception as e:
            logger.error(f"Error processing region {region_name}: {e}")
            continue

    # Create DataFrame
    df = pd.DataFrame(all_results)
    df = df.sort_values(["region", "date"]).reset_index(drop=True)

    logger.info(f"Extracted {len(df)} region-date rainfall records")

    # Save to CSV
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    filename = (
        f"myanmar_chirps_rainfall_{start_date}_{end_date}_{temporal_resolution}.csv"
    )
    output_file = output_path / filename
    df.to_csv(output_file, index=False)
    logger.info(f"Saved data to {output_file}")

    return df


def main():
    """Main function to extract CHIRPS rainfall data for Myanmar."""

    # Path to service account credentials
    service_account_file = (
        "/Users/ssarva/myanmar-economic-monitor/training-253313-c905674c1ca0.json"
    )

    # Authenticate GEE with service account
    authenticate_gee(service_account_file)

    # Set date range - 2020 to 2024
    start_date = "2020-01-01"
    end_date = "2024-12-31"

    logger.info(
        f"\nExtracting rainfall data for Myanmar from {start_date} to {end_date}"
    )

    # Load and process Admin Level 0 (National)
    logger.info("\n" + "=" * 60)
    logger.info("ADMIN LEVEL 0 - National Level")
    logger.info("=" * 60)
    boundaries_path_adm0 = (
        "../../data/boundaries/mmr_polbnda_adm0_250k_mimu_20240215.shp"
    )
    mmr_adm0 = gpd.read_file(boundaries_path_adm0)
    logger.info(f"Loaded {len(mmr_adm0)} national boundary")

    df_adm0 = get_chirps_rainfall_by_region(
        start_date=start_date,
        end_date=end_date,
        regions_gdf=mmr_adm0,
        admin_column="ADM0_EN",
        temporal_resolution="monthly",
        output_dir="../../data/rainfall",
    )

    # Load and process Admin Level 1 (States/Regions)
    logger.info("\n" + "=" * 60)
    logger.info("ADMIN LEVEL 1 - States/Regions Level")
    logger.info("=" * 60)
    boundaries_path_adm1 = (
        "../../data/boundaries/mmr_polbnda_adm1_250k_mimu_20240215.shp"
    )
    mmr_adm1 = gpd.read_file(boundaries_path_adm1)
    logger.info(f"Loaded {len(mmr_adm1)} states/regions")

    df_adm1 = get_chirps_rainfall_by_region(
        start_date=start_date,
        end_date=end_date,
        regions_gdf=mmr_adm1,
        admin_column="ADM1_EN",
        temporal_resolution="monthly",
        output_dir="../../data/rainfall",
    )

    # Display summary statistics
    print("\n" + "=" * 60)
    print("EXTRACTION COMPLETE - MYANMAR RAINFALL DATA")
    print("=" * 60)

    print("\n--- ADMIN LEVEL 0 (National) ---")
    print(f"Total records: {len(df_adm0)}")
    print(f"Regions: {df_adm0['region'].unique()}")

    print("\n--- ADMIN LEVEL 1 (States/Regions) ---")
    print(f"Total records: {len(df_adm1)}")
    print(f"Number of states/regions: {df_adm1['region'].nunique()}")
    print("\nRegions included:")
    for region in sorted(df_adm1["region"].unique()):
        print(f"  - {region}")

    print(f"\nDate range: {df_adm1['date'].min()} to {df_adm1['date'].max()}")


if __name__ == "__main__":
    main()
