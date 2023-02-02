# Agricultural Productivity

Satellite images can capture the intensity of vegetation through the light reflected in the visible and near-infrared bands. The Normalized Difference Vegetation Index (NDVI) has often been used as a proxy of seasonal productivity. To assess changes in agricultural production in Syria, we retrieved anomalies in NDVI from the [Anomaly Hotspots of Agricultural Production](https://mars.jrc.ec.europa.eu/asap/download.php) (ASAP) portal.

In the ASAP portal, NDVI data is originally sourced from MODIS and undergoes additional processing to better capture periods of low agricultural performance. These steps include intersecting NDVI data with croplands and pasture lands, filtering time periods for the relevant crop calendar, and calculating deviations from normal conditions. More information on their data processing and cropland masks can be found on the [documentation pages](https://mars.jrc.ec.europa.eu/asap/files/asap_warning_classification_v_4_0.pdf).

## Data

### Tabular Data

We retrieved data for two NDVI-based anomalies (standardized z-scores) at the sub-national admin 1 level:

- Cumulative: zNDVIc, the standardized score of the cumulative NDVI (NDVIc) over the growing season
- Time of analysis: mNDVId, the mean of the difference between NDVI and its long-term average (NDVId) over the growing season

### Annual Maps

In addition to extracting data from ASAP, we prepared maps that summarize annual performance in agricultural productivity, by comparing the average 2022 NDVI values to previous years. We follow a similar methodology to the one employed by ASAP:

1. Extract NDVI (Modis) data for relevant crop season
2. Mask out non-cropland areas
3. Calculate average annual value and average reference value (2020, or 2021)
4. Substract 2022 annual average from reference period average
5. Export maps

## Implementation

We implemented this workflow on Google Earth Engine:

- [GEE NDVI Annual Anomalies](https://raw.githubusercontent.com/datapartnership/syria-economic-monitor/main/notebooks/ndvi/gee_ndvi_annual_anomalies.js)

## Findings

We find that agricultural productivity has dropped significantly in 2022 relative to historical conditions, particularly in Al-Hasakeh, Deir-ez-Zor, and Aleppo.

```{figure} ../../reports/figures/syria_ndvi_map_2022.jpg
---
align: center
---
Average NDVI Value Comparison between 2020 and 2022.
```
