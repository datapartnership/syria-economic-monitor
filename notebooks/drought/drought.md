# Drought Analytics
## Overview

This chapter focuses on utilizing historical precipitation data from 2000 to 2024 to analyze moisture trends and drought levels over time at national and subnational levels.This chapter inludes two notebooks namely drought_spei and drought_analysis_chirps.

- *Drought_spei* : This notebook used the Spei (Standard Precipitation Evapotranspiration Index) data from the [Global SPEI Database](https://spei.csic.es/database.html). Since this data is not updated for the year of 2024, this notebook provides drought analysis until 2023 on national level

- *Drought_analysis_CHIRPS* : This notebook calculates the SPI values( Standard Precipitation Index) from the latest [CHIRPS 3.0](https://www.chc.ucsb.edu/data/chirps3) and provides moisture trends as well as drought classifications from 2000 to 2024 at national and subnational levels.

## Data

The following datasets are utilized in this analysis for calculating precipitation Indices and generating moisture trends over the past years:

1. **SPEIbase (Standardized Precipitation-Evapotranspiration Index):**
- **Source**: The Global SPEI database (SPEIbase) is developed by the Climatic Research Unit (CRU) at the University of East Anglia. It provides long-term, standardized drought index data based on precipitation and potential evapotranspiration estimates. The latest version, SPEIbase v2.10, is based on the CRU TS 4.08 dataset spanning January 1901 – December 2023. SPEIbase v2.10 Data Access
- **Description**: The dataset offers global drought monitoring using the Standardized Precipitation-Evapotranspiration Index (SPEI), a key measure of water balance variability. It uses the FAO-56 Penman-Monteith method to estimate potential evapotranspiration, providing a multi-scale drought index with time scales from 1 to 48 months. SPEIbase is suitable for long-term climatological analysis, allowing assessment of drought severity and frequency.
- **Spatial Resolution**: 0.5° (~50 km grid resolution).
Temporal Coverage: Monthly data from January 1901 to the present, continuously updated with new CRU dataset releases.
- **Use Case**: SPEIbase is widely used for climate change studies, agricultural drought monitoring, water resource management, and ecological impact assessments. It provides insights into historical and ongoing drought conditions, helping researchers and policymakers analyze climate trends over time.
- **Data Format:** The dataset is available in netCDF format, ensuring compatibility with various climate analysis tools.

2. **CHIRPS 3.0 (Climate Hazards InfraRed Precipitation with Station Data):**
- **Source**: Developed by the Climate Hazards Center, CHIRPS 3.0 is a high-resolution global precipitation dataset funded by USAID, NASA, and NOAA. The dataset integrates rain gauge observations with satellite-based estimates for improved rainfall monitoring. CHIRPS v3.0 Data Access
- **Description**: CHIRPS 3.0 provides enhanced rainfall estimates using satellite thermal infrared data and an upgraded climatology model (CHPclim2). It incorporates more station observations and improved bias corrections, making it a more reliable precipitation dataset compared to its predecessor, CHIRPS v2.0. The new CHIRP3 algorithm better estimates a wider range of precipitation values, which is especially useful for capturing extreme weather events and seasonal variations.
- **Spatial Resolution**: ~5 km (0.05° degree grid resolution).
- **Temporal Coverage**: CHIRPS 3.0 data is available from 1981 to the present, with updates provided at pentad (5-day) and monthly intervals.
- **Use Case**: The dataset is widely used for drought monitoring, agricultural planning, hydrological modeling, and climate research. It is particularly valuable for early warning systems and food security assessments in regions vulnerable to climate variability
- **Data Format**: The data is available in downloadable global tiff images, which are then clipped for Syria admin level 0 boundaries and processed into a NetCDF format with time, lon and lat dimensions.


3. **Administrative Boundaries (HDX)**:
   - **Source**: Humanitarian Data Exchange [HDX](https://data.humdata.org/).
   - **Description**: Geographic boundaries used for spatial aggregation and administrative analysis, such as calculating productivity metrics by region (e.g., governorate or district).
   - **Use Case**: The administrative boundaries are used to aggregate EVI statistics by region and facilitate reporting at various administrative levels.

## Summary of Analysis Outputs
**Part 1:** [Drought Analysis using SPEI Database](./drought_spei.ipynb)

**Part 2:** [Drought Analysis using CHIRPS Data](./drought_analysis_chirps.ipynb)
