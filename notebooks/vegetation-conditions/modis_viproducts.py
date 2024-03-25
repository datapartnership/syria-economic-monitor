# -*- coding: utf-8 -*-
"""
NAME
    modis_viproducts.py
    Generate derivative product from Vegetation Indices
DESCRIPTION
    Input data for this script will use MXD13Q1 8-days data generate from GEE or downloaded
    from NASA. This script can do calculation for ratio, difference, standardize anomaly
    and vegetation condition index.
    The calculation required timeseries VI and the long-term statistics (min, mean, max, std)
REQUIREMENT
    ArcGIS must installed before using this script, as it required arcpy module.
EXAMPLES
    C:\\Program Files\\ArcGIS\\Pro\\bin\\Python\\envs\\arcgispro-py3\\python modis_viproducts.py
NOTES
    This script is designed to work with MODIS naming convention
    If using other data, some adjustment are required: parsing filename and directory
CONTACT
    Benny Istanto
    Climate Geographer
    GOST, The World Bank
LICENSE
    This script is in the public domain, free from copyrights or restrictions.
VERSION
    $Id$
TODO
    xx
"""

import os
import arcpy
from datetime import datetime, timedelta

# To avoid overwriting outputs, change overwriteOutput option to False.
arcpy.env.overwriteOutput = True

# ISO3 Country Code
iso3 = "syr"  # Myanmar

# Define input and output folders
input_folder = "X:\\Temp\\modis\\{}\\gee\\02_positive\\all".format(iso3)
stats_folder = "X:\\Temp\\modis\\{}\\gee\\03_statistics\\all".format(iso3)
ratioanom_folder = "X:\\Temp\\modis\\{}\\gee\\05_ratioanom\\temp\\all".format(iso3)
diffanom_folder = "X:\\Temp\\modis\\{}\\gee\\06_diffanom\\temp\\all".format(iso3)
stdanom_folder = "X:\\Temp\\modis\\{}\\gee\\07_stdanom\\temp\\all".format(iso3)
vci_folder = "X:\\Temp\\modis\\{}\\gee\\08_vci\\temp\\all".format(iso3)


def derivative_vi(
    input_folder,
    stats_folder,
    ratioanom_folder,
    diffanom_folder,
    stdanom_folder,
    vci_folder,
):
    # Loop through the files in the input folder
    for raster in os.listdir(input_folder):
        # Check if the file is a TIFF file
        if raster.endswith(".tif") or raster.endswith(".tiff"):
            # Get the year, month, and day or day of year from the raster name
            # syr_phy_mxd13q1_evi_20020101.tif
            if "_" in raster:
                year = int(raster[20:24])
                month = int(raster[24:26])
                day = int(raster[26:28])
                date = datetime(year, month, day)
                doy = date.strftime("%j")
            else:
                year = int(raster[20:24])
                doy = int(raster[24:27])
                leap_year = datetime(year, 2, 29).strftime("%j") != "059"
                if leap_year:
                    doy += 1
                    date = datetime(year, 1, 1) + timedelta(doy - 1)

            # Get the DOY from the date
            doy = date.strftime("%j")

            # Construct the corresponding filenames in the stats folder
            avg_raster = "{0}_phy_mxd13q1_20yr_avg_{1}.tif".format(iso3, doy.zfill(3))
            min_raster = "{0}_phy_mxd13q1_20yr_min_{1}.tif".format(iso3, doy.zfill(3))
            max_raster = "{0}_phy_mxd13q1_20yr_max_{1}.tif".format(iso3, doy.zfill(3))
            std_raster = "{0}_phy_mxd13q1_20yr_std_{1}.tif".format(iso3, doy.zfill(3))
            avg_raster = os.path.join(stats_folder, avg_raster)
            min_raster = os.path.join(stats_folder, min_raster)
            max_raster = os.path.join(stats_folder, max_raster)
            std_raster = os.path.join(stats_folder, std_raster)

            # Check if the corresponding rasters exist in the stats folder
            for raster in [avg_raster, min_raster, max_raster, std_raster]:
                if not arcpy.Exists(raster):
                    print("Error: {} not found in {}".format(raster, stats_folder))
                    continue

            # Create the output raster name with the appropriate format
            # Ratio anomaly
            if "_" in raster:
                ratioanom_raster = os.path.join(
                    ratioanom_folder,
                    "{}_phy_mxd13q1_ratioanom_{}{:02d}{:02d}.tif".format(
                        iso3, year, month, day
                    ),
                )
            else:
                ratioanom_raster = os.path.join(
                    ratioanom_folder,
                    "{}_phy_mxd13q1_ratioanom_{}{}.tif".format(
                        iso3, year, doy.zfill(3)
                    ),
                )
            # Difference anomaly
            if "_" in raster:
                diffanom_raster = os.path.join(
                    diffanom_folder,
                    "{}_phy_mxd13q1_diffanom_{}{:02d}{:02d}.tif".format(
                        iso3, year, month, day
                    ),
                )
            else:
                diffanom_raster = os.path.join(
                    diffanom_folder,
                    "{}_phy_mxd13q1_diffanom_{}{}.tif".format(iso3, year, doy.zfill(3)),
                )
            # Standardize anomaly
            if "_" in raster:
                stdanom_raster = os.path.join(
                    stdanom_folder,
                    "{}_phy_mxd13q1_stdanom_{}{:02d}{:02d}.tif".format(
                        iso3, year, month, day
                    ),
                )
            else:
                stdanom_raster = os.path.join(
                    stdanom_folder,
                    "{}_phy_mxd13q1_stdanom_{}{}.tif".format(iso3, year, doy.zfill(3)),
                )
            # Vegetation condition index
            if "_" in raster:
                vci_raster = os.path.join(
                    vci_folder,
                    "{}_phy_mxd13q1_vci_{}{:02d}{:02d}.tif".format(
                        iso3, year, month, day
                    ),
                )
            else:
                vci_raster = os.path.join(
                    vci_folder,
                    "{}_phy_mxd13q1_vci_{}{}.tif".format(iso3, year, doy.zfill(3)),
                )

            arcpy.CheckOutExtension("spatial")

            # Prepared the input
            in_raster = arcpy.Raster(os.path.join(input_folder, raster))
            avg_raster = arcpy.Raster(avg_raster)
            min_raster = arcpy.Raster(min_raster)
            max_raster = arcpy.Raster(max_raster)
            std_raster = arcpy.Raster(std_raster)

            # Calculate the indices
            ratioanom = arcpy.sa.Int(100 * in_raster / avg_raster)
            diffanom = (in_raster * 0.0001) - (avg_raster * 0.0001)
            stdanom = (in_raster - avg_raster) / std_raster
            vci = 100 * (
                (arcpy.sa.Float(in_raster) - arcpy.sa.Float(min_raster))
                / (arcpy.sa.Float(max_raster) - arcpy.sa.Float(min_raster))
            )

            # Save the output raster
            ratioanom.save(ratioanom_raster)
            print(ratioanom_raster + " completed")
            diffanom.save(diffanom_raster)
            print(diffanom_raster + " completed")
            stdanom.save(stdanom_raster)
            print(stdanom_raster + " completed")
            vci.save(vci_raster)
            print(vci_raster + " completed")

            arcpy.CheckInExtension("spatial")


# Main function
def main():
    # Call the vci() function for the input folder
    derivative_vi(
        input_folder,
        stats_folder,
        ratioanom_folder,
        diffanom_folder,
        stdanom_folder,
        vci_folder,
    )


if __name__ == "__main__":
    main()
