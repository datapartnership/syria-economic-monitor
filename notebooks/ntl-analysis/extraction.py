import os
from pathlib import Path
import geopandas as gpd
import pandas as pd
import pyreadr

import numpy as np
from rasterstats import zonal_stats
from getpass import getpass
from dotenv import dotenv_values
from blackmarble import BlackMarble, Product
from blackmarble import raster, extract

# Get repo root directory (3 levels up from this script: nighttime-lights -> notebooks -> repo_root)
REPO_ROOT = Path(__file__).resolve().parent.parent.parent
DATA_DIR = REPO_ROOT / "data"
BOUNDARIES_DIR = REPO_ROOT / "boundaries"

secrets_path = Path.home() / ".config" / "ethiopia-economic-monitor" / "secrets.env"
secrets = dotenv_values(secrets_path)
blackmarble_token = secrets.get("BLACKMARBLE_TOKEN", "").strip()

if not blackmarble_token:
    blackmarble_token = getpass("Enter BlackMarble token (input hidden): ").strip()
    secrets_path.parent.mkdir(parents=True, exist_ok=True)
    secrets_path.write_text(f"BLACKMARBLE_TOKEN={blackmarble_token}\n")
    os.chmod(secrets_path, 0o600)

bm = BlackMarble(token=blackmarble_token)

adm0 = gpd.read_file(DATA_DIR / "boundaries/syr_admin0.shp")
adm1 = gpd.read_file(DATA_DIR / "boundaries/syr_admin1.shp")
adm2 = gpd.read_file(DATA_DIR / "boundaries/syr_admin2.shp")
adm3 = gpd.read_file(DATA_DIR / "boundaries/syr_admin3.shp")


gas_flaring_rds = pyreadr.read_r(str(DATA_DIR / "ntl/gas_flare_locations.Rds"))
gas_flaring = gas_flaring_rds[None]  # Extract the dataframe from the RDS object
gas_flaring_10km = gpd.GeoDataFrame(
    gas_flaring,
    geometry=gpd.points_from_xy(gas_flaring.longitude, gas_flaring.latitude),
    crs="EPSG:4326",
)
gas_flaring_10km["geometry"] = (
    gas_flaring_10km.to_crs(epsg=32647).buffer(10000).to_crs(gas_flaring_10km.crs)
)

gas_flaring_5km = gpd.GeoDataFrame(
    gas_flaring,
    geometry=gpd.points_from_xy(gas_flaring.longitude, gas_flaring.latitude),
    crs="EPSG:4326",
)
gas_flaring_5km["geometry"] = (
    gas_flaring_5km.to_crs(epsg=32647).buffer(5000).to_crs(gas_flaring_5km.crs)
)

# Dissolve gas flaring buffers into single union geometries
gf_5km_union = gas_flaring_5km.union_all()
gf_10km_union = gas_flaring_10km.union_all()

# Ensure unions are in EPSG:4326
if hasattr(gf_5km_union, "__geo_interface__"):
    gf_5km_union = gpd.GeoSeries([gf_5km_union], crs=gas_flaring_5km.crs).to_crs(
        "EPSG:4326"
    )[0]
    gf_10km_union = gpd.GeoSeries([gf_10km_union], crs=gas_flaring_10km.crs).to_crs(
        "EPSG:4326"
    )[0]


def make_mask_variants(gdf, mask_union):
    """Create masked and inverse-masked versions of admin boundaries."""
    gdf = gdf.copy()
    gdf["_merge_id"] = range(len(gdf))

    gdf_in = gdf.copy()
    gdf_in["geometry"] = gdf_in.geometry.intersection(mask_union)
    gdf_in["geometry"] = gdf_in.geometry.make_valid()
    gdf_in = gdf_in[~gdf_in.is_empty & gdf_in.geometry.is_valid].reset_index(drop=True)

    gdf_out = gdf.copy()
    gdf_out["geometry"] = gdf_out.geometry.difference(mask_union)
    gdf_out["geometry"] = gdf_out.geometry.make_valid()
    gdf_out = gdf_out[~gdf_out.is_empty & gdf_out.geometry.is_valid].reset_index(
        drop=True
    )

    return gdf, gdf_in, gdf_out


def extract_mask_variant(gdf_variant, rasters_ds, col_name):
    """Extract zonal stats from in-memory rasters for a mask variant."""
    if gdf_variant.empty:
        return None
    try:
        var_name = [v for v in rasters_ds.data_vars][0]
        da = rasters_ds[var_name]
        time_dim = "time" if "time" in da.dims else da.dims[0]
        records = []
        for t_idx in range(da.sizes[time_dim]):
            slice_da = da.isel({time_dim: t_idx})
            arr = slice_da.values.astype("float64")
            transform = slice_da.rio.transform()
            nodata = da.rio.nodata
            if nodata is not None:
                arr[arr == nodata] = np.nan
            stats = zonal_stats(
                gdf_variant,
                arr,
                affine=transform,
                stats=["sum"],
                nodata=np.nan,
                all_touched=True,
            )
            date_val = pd.Timestamp(da[time_dim].values[t_idx])
            for i, s in enumerate(stats):
                records.append(
                    {
                        "_merge_id": gdf_variant.iloc[i]["_merge_id"],
                        "date": date_val,
                        col_name: s["sum"] if s["sum"] is not None else 0.0,
                    }
                )
        return pd.DataFrame(records)
    except Exception as e:
        print(f"  Warning: skipping {col_name} — {e}")
        return None


# Prepare admin boundaries
for gdf in [adm0, adm1, adm2, adm3]:
    if "date" in gdf.columns:
        gdf.drop(columns="date", inplace=True)
    # Make sure geometries are valid
    gdf["geometry"] = gdf.geometry.make_valid()
    # Ensure proper CRS
    if gdf.crs is None:
        gdf.set_crs("EPSG:4326", inplace=True)
    elif gdf.crs.to_string() != "EPSG:4326":
        gdf.to_crs("EPSG:4326", inplace=True)

start_date = "2012-01-01"
end_date_monthly = "2026-03-01"

end_date_annual = "2025-01-01"

for products in [Product.VNP46A3]:
    if products == Product.VNP46A4:
        print("Extracting VNP46A4 (annual composites)...")
        freq = "YS"
        folder = "annual"
        end_date = end_date_annual

    else:
        print("Extracting VNP46A3 (monthly composites)...")
        freq = "MS"
        folder = "monthly"
        end_date = end_date_monthly

    # Raw h5 files directory (existing files)
    raw_dir = DATA_DIR / f"ntl/raw/{folder}"
    raw_dir.mkdir(parents=True, exist_ok=True)

    # Processed rasters directory
    raster_dir = DATA_DIR / "ntl/raw/"
    raster_dir.mkdir(parents=True, exist_ok=True)

    # Aggregated CSV output directory
    aggregated_dir = DATA_DIR / f"ntl/aggregated/{folder}"
    aggregated_dir.mkdir(parents=True, exist_ok=True)

    # Check if all outputs already exist - skip product entirely if so
    all_exist = all(
        (aggregated_dir / f"ntl_syr_adm{level}_{folder}.csv").exists()
        for level in [0, 1, 2, 3]
    )
    if all_exist:
        print(f"All outputs exist for {folder} - skipping {products.name}")
        continue

    # Check if processed rasters exist
    date_range = pd.date_range(start_date, end_date, freq=freq)
    product_name = products.name  # VNP46A3 or VNP46A4
    raster_files_exist = all(
        (raster_dir / f"{product_name}_{date.strftime('%Y%m%d')}.tif").exists()
        for date in date_range
    )

    if raster_files_exist:
        print(f"Rasters already exist for {folder} - skipping raster generation")
    else:
        print(f"Generating rasters for {folder}...")
        rasters = raster.bm_raster(
            adm0,
            products,
            date_range,
            token=blackmarble_token,
            output_directory=str(raw_dir),
            output_skip_if_exists=True,
        )

        # Save processed rasters
        print(f"Saving processed rasters to {raster_dir}")
        for var in rasters.data_vars:
            da = rasters[var]
            time_dim = "time" if "time" in da.dims else da.dims[0]
            for t_idx in range(da.sizes[time_dim]):
                slice_da = da.isel({time_dim: t_idx})
                date_val = pd.Timestamp(da[time_dim].values[t_idx])
                date_str = date_val.strftime("%Y%m%d")
                product_name = products.name  # VNP46A3 or VNP46A4
                out_file = raster_dir / f"{product_name}_{date_str}.tif"
                slice_da.rio.to_raster(out_file)

    for admin_level, eth_gdf in zip([0, 1, 2, 3], [adm0, adm1, adm2, adm3]):
        # Check if output already exists - skip if so
        out_path = aggregated_dir / f"ntl_syr_adm{admin_level}_{folder}.csv"
        if out_path.exists():
            print(
                f"Skipping admin level {admin_level} - output already exists: {out_path}"
            )
            continue

        print(f"Extracting for admin level {admin_level}...")

        date_range = pd.date_range(start_date, end_date, freq=freq)
        extract_kwargs = dict(
            product_id=products,
            date_range=date_range,
            token=blackmarble_token,
            output_directory=str(raw_dir),  # Use raw directory with existing h5 files
            output_skip_if_exists=True,
        )

        # Create masked variants for gas flaring
        gdf_with_id, gdf_gf_5km, gdf_nogf_5km = make_mask_variants(
            eth_gdf, gf_5km_union
        )
        _, gdf_gf_10km, gdf_nogf_10km = make_mask_variants(eth_gdf, gf_10km_union)

        # Extract total NTL (ntl_sum)
        extracted = extract.bm_extract(gdf_with_id, **extract_kwargs)

        # Extract gas flaring masked variants using bm_extract
        for gdf_variant, prefix in [
            (gdf_gf_5km, "ntl_gf_5km"),
            (gdf_nogf_5km, "ntl_nogf_5km"),
            (gdf_gf_10km, "ntl_gf_10km"),
            (gdf_nogf_10km, "ntl_nogf_10km"),
        ]:
            if not gdf_variant.empty:
                try:
                    col_name = f"{prefix}_sum"
                    variant_extracted = extract.bm_extract(
                        gdf_variant, **extract_kwargs
                    )
                    # Rename ntl_sum to the appropriate mask column name
                    variant_extracted = variant_extracted.rename(
                        columns={"ntl_sum": col_name}
                    )
                    # Merge on _merge_id and date
                    extracted = extracted.merge(
                        variant_extracted[["_merge_id", "date", col_name]],
                        on=["_merge_id", "date"],
                        how="left",
                    )
                except Exception as e:
                    print(f"  Warning: skipping {prefix} — {e}")
                    extracted[col_name] = 0.0
            else:
                extracted[f"{prefix}_sum"] = 0.0

        # Fill NaN for admin areas with no gas flaring overlap
        mask_cols = [
            "ntl_gf_5km_sum",
            "ntl_nogf_5km_sum",
            "ntl_gf_10km_sum",
            "ntl_nogf_10km_sum",
        ]
        for col in mask_cols:
            extracted[col] = extracted[col].fillna(0.0)

        out_path = aggregated_dir / f"ntl_syr_adm{admin_level}_{folder}.csv"
        extracted.drop(
            columns=["geometry", "_merge_id", "_join_id"], errors="ignore"
        ).to_csv(out_path, index=False)
