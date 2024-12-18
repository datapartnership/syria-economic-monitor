# Vegetation Analytics
## Overview

This notebook analyzes crop productivity trends from 2018 to 2024 using satellite-derived Enhanced Vegetation Index (EVI) data, cropland extent information, and supporting spatial datasets. The analysis focuses on quantifying yearly productive areas, mapping changes in agricultural productivity, and identifying regions where expected plantings did not occur in 2023 and 2024.

## Data

The following datasets are utilized in this analysis for calculating and mapping crop productivity over the past years:

1. **MODIS EVI (Enhanced Vegetation Index) Data**:
   - **Source**: NASA's Moderate Resolution Imaging Spectroradiometer [MODIS](https://modis.gsfc.nasa.gov/data/) on the Terra and Aqua satellites.
   - **Description**: The dataset provides the Enhanced Vegetation Index (EVI), which is an optimized vegetation index designed to improve sensitivity in regions with dense vegetation while minimizing soil background influences.
   - **Spatial Resolution**: 250 meters.
   - **Temporal Coverage**: Data is collected every 16 days. This analysis focuses on yearly aggregated EVI values from 2018 to 2024.
   - **Use Case**: The EVI data is used to identify productive cropland areas by applying thresholds indicative of healthy vegetation.

2.**DEA Cropland Mask**:
   - **Source:** ESA WorldCover - European Space Agency
   - **Description:** [The ESA WorldCover dataset](https://developers.google.com/earth-engine/datasets/catalog/ESA_WorldCover_v100) is a global land cover map at 10-meter resolution developed by the European Space Agency (ESA). It utilizes Sentinel-1 and Sentinel-2 data along with advanced machine learning algorithms to classify land cover into 11 distinct classes, including cropland, forest, grassland, and built-up areas. The dataset is designed to provide consistent and accurate land cover information across the globe, supporting various environmental and socio-economic applications.
   - **Use Case:** This crop mask is used for agricultural monitoring, land use planning, food security assessments, and environmental management. It provides valuable insights into the distribution and extent of cropland, aiding decision-making processes related to sustainable agricultural practices and resource management in Africa.

3. **Administrative Boundaries (HDX)**:
   - **Source**: Humanitarian Data Exchange [HDX](https://data.humdata.org/).
   - **Description**: Geographic boundaries used for spatial aggregation and administrative analysis, such as calculating productivity metrics by region (e.g., governorate or district).
   - **Use Case**: The administrative boundaries are used to aggregate EVI statistics by region and facilitate reporting at various administrative levels.

4. **ACLED Conflict Data**:
   - **Source**: [ACLED](https://acleddata.com/data/) provides real-time data on conflict events worldwide.
   - **Description**: Conflict data was sourced from the ACLED database, which provides detailed records of events such as battles, protests, and other violent activities, including attributes like event type, date, and number of fatalities.The dataset was loaded as a CSV and converted to a GeoDataFrame (acled_gdf), with geometries representing the event locations.
   -**Use Case**: Used for conflict monitoring, risk assessment, and informing humanitarian policies.

## Summary of Analysis Outputs
**Part 1:** [Crop Productivity and time series analytics](./evi-analytics.ipynb)

**Part 2:** [EVI, Temperature and Rainfall Updates](./ChangeMaps.ipynb)

**Part 3:** [Land Use Change](./lulc.ipynb)

**Part 4:** [Drought-EVI Analysis](./drought.ipynb)
