# Traffic Trends at Border Crossings

We monitor trends in traffic along key border crossings in Syria. When vehicle count data captured along roads is not available, other data sources can be used to detect traffic and congestion---such as mobility data and satellite imagery. In this analysis, we test the use of three data sources for monitoring trends in traffic at three border crossings.

## Data

We test to the use of three data sources for monitoring trends in traffic at border crossings. We leverage three data sources as each data source comes with its own set of advantages and limitations. The three data sources are:

* __Very High Resolution Satellite Imagery__: We use very high resolution (VHR) daytime satellite imagery from [Orbital Insight](https://orbitalinsight.com/). Orbital Insight has developed algorithms for detecting cars and trucks from satellite imagery that has less than 1 meter spatial resolution. From such high resolution images, cars and trucks can be easily detected using Orbital Insight's algorithms. However, a key limitation of using VHR data for detecting trends in traffic is that VHR satellite images used by Orbital Insight are not captured at regular intervals. Consequently, the number of images available can vary across locations.

* __Medium Resolution Synthetic Aperture Radar Satellite Imagery:__ We use synthetic aperture radar (SAR) satellite imagery captured from Sentinel-1, which is available at a 10 meter resolution. SAR satellites transmit waves and measure the strength and orientation of waves reflected back to the satellite. Different objects scatter waves differently, and metallic objects such as vehicles produce a strong signal back to the sensor {cite:p}`Dirk2014`. [SpaceKnow](https://spaceknow.com/) has developed algorithms that use SAR data from Sentinel-1 to detect trends in congestion. Unlike VHR imagery, SAR data is not able to count the number of vehicles; however, Sentinel-1 captures SAR data at regular intervals (multiple times a month). SpaceKnow leverages SAR data to develop a traffic index, where larger values correspond to more congestion.

* __Mobility Data:__ We leverage mobility data from GPS-enabled devices to monitor the number of unique devices at border crossing locations. Mobility data comes from Outlogic, which is further described in {doc}`../mobility/README`. The number of unique devices observed at border crossing locations can indicate activity---and traffic---at the crossing. A key advantage of mobility data over satellite imagery is that it is available at all points in time; the dataset captures the timestamp and location of GPS-enable devices. Consequently, the data can be aggregated hourly, daily, or at other intervals. Mobility data may underestimate activity as not everyone may have a GPS-enabled device; however, we check whether trends in mobility data are similar to trends captured from satellite imagery.

For further information, please refer to {ref}`foundational_datasets`.

## Implementation

Code to analyze traffic across the three data sources is available [here](https://github.com/datapartnership/syria-economic-monitor/tree/main/notebooks/traffic/traffic_analysis.R).

## Findings

The below figure shows trends in the traffic indicators from the three sources. VHR images are captured at irregular intervals, so car and truck counts are available at limited points in time. However, comparing the VHR and mobility data emphasizes the downward bias in the mobility data. VHR data shows up to 250 vehicles captured at a single point in time for a border crossing, while mobility data from Outlogic only shows up to 12 unique devices captured during a day. Outlogic data may have too few observations at the border crossing locations to meaningfully observe trends. The traffic index from SAR imagery shows a notable increase in traffic at the Al Abbudiyah border crossing in 2022, a slight upward trend in traffic at the Al Aridah border crossing, and relatively consistent traffic at the Matraba border crossing.

```{figure} ../../reports/figures/border_trends_sat_mobility.png
---
align: center
---
Trends in Traffic using Different Data Sources. Data aggregated to the monthly level; when multiple observations are available within the month, we use the maximum.
```

## Next Steps

Next steps can focus on piloting the data sources at additional border crossings. As the availability of VHR imagery can vary across locations, certain border crossings may have higher frequency VHR imagery where meaningful trends can be determined. As the WB Data Lab team has Outlogic data available across the country, trends could be examined across all border crossings to understand if some locations have higher volumes of mobility data. Ground-truth the data sources with traffic count data obtained at border crossings would also provide useful in understanding the usefulness and biases of the different data sources.

## References

```{bibliography}
```
