# -*- coding: utf-8 -*-
"""
NAME
    modis_8daystats.py
    MXD13Q1 8-days statistics data, long-term average, max, min and stdev
DESCRIPTION
    Input data for this script will use MXD13Q1 8-days data generate from GEE or downloaded from NASA
    This script can do 8-days statistics calculation (AVERAGE, MAXIMUM, MINIMUM and STD)
REQUIREMENT
    ArcGIS must installed before using this script, as it required arcpy module.
EXAMPLES
    C:\\Program Files\\ArcGIS\\Pro\\bin\\Python\\envs\\arcgispro-py3\\python modis_16daystats.py
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
from collections import defaultdict
from datetime import datetime, timedelta

# To avoid overwriting outputs, change overwriteOutput option to False.
arcpy.env.overwriteOutput = True

# ISO3 Country Code
iso3 = "mmr" # Myanmar

# Change the data and output folder
input_folder = "X:\\Temp\\modis\\{}\\gee\\02_positive\\temp".format(iso3)
output_folder = "X:\\Temp\\modis\\{}\\gee\\03_statistics\\temp".format(iso3)

# Create file collection based on date information
groups = defaultdict(list)

for file in os.listdir(input_folder):
    if file.endswith(".tif") or file.endswith(".tiff"):
        # Parsing the filename to get date information
        parts = file.split("_")
        date_str = parts[-1].split(".")[0]  # remove the file extension
        date = datetime.strptime(date_str, "%Y%m%d")
        doy = date.strftime("%j")
        
        if doy == "366" and not calendar.isleap(date.year):
            # This is not a leap year but has a DOY 366, skip it.
            continue
        else:
            # Add the file to the group for its DOY.
            groupkey = doy
            groups[groupkey].append(os.path.join(input_folder, file))

# Define statistic names
# Statistics type.
    # MEAN — The mean (average) of the inputs will be calculated.
    # MAJORITY — The majority (value that occurs most often) of the inputs will be determined.
    # MAXIMUM — The maximum (largest value) of the inputs will be determined.
    # MEDIAN — The median of the inputs will be calculated. Note: The input must in integers
    # MINIMUM — The minimum (smallest value) of the inputs will be determined.
    # MINORITY — The minority (value that occurs least often) of the inputs will be determined.
    # RANGE — The range (difference between largest and smallest value) of the inputs will be calculated.
    # STD — The standard deviation of the inputs will be calculated.
    # SUM — The sum (total of all values) of the inputs will be calculated.
    # VARIETY — The variety (number of unique values) of the inputs will be calculated.
stat_names = {"MAXIMUM": "max", "MINIMUM": "min", "MEAN": "avg", "MEDIAN": "med", "STD": "std"}

for groupkey, files in groups.items():
    print(files)

    # Output file extension
    ext = ".tif"

    # Output filenames
    newfilenames = [
        f"{iso3}_phy_mxd13q1_20yr_{stat}_{groupkey.zfill(3)}{ext}"
        for stat in stat_names.values()
    ]

    for i, filename in enumerate(newfilenames):
        if arcpy.Exists(os.path.join(output_folder, filename)):
            print(filename + " exists")
        else:
            stat_type = list(stat_names.keys())[list(stat_names.values()).index(list(stat_names.values())[i])]
            
            arcpy.CheckOutExtension("spatial")
            outCellStatistics = arcpy.sa.CellStatistics(files, stat_type, "DATA")
            outCellStatistics.save(os.path.join(output_folder, filename))
            arcpy.CheckInExtension("spatial")

            print(filename + " completed")
    
