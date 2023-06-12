# 2023 Summer Economic Monitor Insights

In addition to broadening our understanding of key economic sectors, the Syria Economic Monitor 2023 summer update also looks at economic impacts of  the February 6 earthquake in Turkiye and northern Syria, which affected the livelihoods of thousands of people and caused cascading economic disruption. 

Support for this edition of the Monitor includes use of alternative data to better understand changing trends in:

* Maritime-based trade using AIS transponder data

* Agricultural productivity through remote sensing

* Changing centers of economic activity, as observed through mobility data and nighttime lights

* Environment - deforestation, air quality, and GHG emissions - through remote sensing

* Movement between Turkiye and Syria. 

The following sections represent sample insights and analytics, prepared for use by the Syria Economic Monitor team and intended to be combined with other resources and local knowledge to create a complete understanding of the changing economic conditions in this fragile county. Datasets and methods for all insights are presented in the previous sections, and a set of indicators have been prepared as an [Excel workbook](https://worldbankgroup.sharepoint.com/:x:/t/DevelopmentDataPartnershipCommunity-WBGroup/EXZkY4Z6vMVMjRVcIBCHqlkBVI4z1b9rP1fyyLQ6aluvWA?e=pFazxV), accessible via the [Project Sharepoint](https://worldbankgroup.sharepoint.com/:f:/r/teams/DevelopmentDataPartnershipCommunity-WBGroup/Shared%20Documents/Projects/Data%20Lab/Syria%20Economic%20Monitor?csf=1&web=1&e=vn3ybj).

## Nighttime Lights

We examine trends in daily nighttime lights from before and after the February 6 earthquake. Analysis of nighttime lights reveals that: (1) in the immediate days after the earthquake (~3 days), nighttime light fell, (2) in the 2 weeks after the earthquake, nighttime lights increase---particularly in the area most affected by the earthquake---likely indicating lights from rescue efforts, and (3) many locations hardest hit by the earthquake had lower nighttime lights in March 2023 compared to January.

### Trends in Nighttime Lights by Earthquake Intensity

The below figures show daily trends (and a 7 day moving average from daily data) in nighttime lights from October 1, 2022 through April 30, 2023. The first figure shows average values across subdistricts by earthquake intensity. The next two figures show nighttime lights in the most affected subdistricts. The last figure shows trends in nighttime lights in border crossing locations.

```{figure} ../reports/figures/ntl_eq_avg.png
---
scale: 50%
align: center
---
Average Trends in Nighttime Lights by Earthquake Intensity. The red line indicates February 6, 2023.
```

```{figure} ../reports/figures/ntl_eq_very_strong.png
---
scale: 50%
align: center
---
Earthquake Intensity: Very Strong - Trends in Nighttime Lights. The red line indicates February 6, 2023.
```

```{figure} ../reports/figures/ntl_eq_strong.png
---
scale: 50%
align: center
---
Earthquake Intensity: Very Strong - Trends in Nighttime Lights. The red line indicates February 6, 2023.
```

```{figure} ../reports/figures/ntl_border_xing.png
---
scale: 50%
align: center
---
Trends in Nighttime Lights in Border Crossing Locations. The red line indicates February 6, 2023.
```

### Maps of Percent Change in Nighttime Lights

The below maps show the percent change in nighttime lights. The figures use nighttime lights in January 2023 as baseline, and compute percent change using data (1) 3 days after the earthquake, (2) 14 days after the earthquake, and (3) in March. The first three maps show data across all of Syria, and the next three maps focus on areas where the earthquake intensity was moderate or higher. 

#### All of Syria

```{figure} ../reports/figures/map_ntl_eq_3d.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to 3 Days After Earthquake. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

```{figure} ../reports/figures/map_ntl_eq_14d.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to 2 Weeks After Earthquake. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

```{figure} ../reports/figures/map_ntl_eq_march.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to March. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

#### Subdistricts with Moderate or Higher Earthquake Intensity

```{figure} ../reports/figures/map_ntl_eq_3d_strong.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to 3 Days After Earthquake. The black line show locations where the earthquake intensity was very strong.
```

```{figure} ../reports/figures/map_ntl_eq_14d_strong.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to 2 Weeks After Earthquake. The black line show locations where the earthquake intensity was very strong.
```

```{figure} ../reports/figures/map_ntl_eq_march_strong.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights: January to March. The black line show locations where the earthquake intensity was very strong.
```

### Maps of Percent Change in Nighttime Lights - Only Considering Gas Flaring Locations

```{figure} ../reports/figures/map_ntl_gf_eq_3d.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights in Gas Flaring Locations: January to 3 Days After Earthquake. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

```{figure} ../reports/figures/map_ntl_gf_eq_14d.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights in Gas Flaring Locations: January to 2 Weeks After Earthquake. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

```{figure} ../reports/figures/map_ntl_gf_eq_march.png
---
scale: 50%
align: center
---
Percent Change in Nighttime Lights in Gas Flaring Locations: January to March. The two black lines show locations where the earthquake intensity was (a) very strong and (b) strong.
```

## Seaborn Trade Activity Estimation

Firstly, we update our estimates of trade activity, with AIS (Automatic Identification System) data up to June 1st, 2023. We apply the same methodology described in our earlier [documentation notes](https://datapartnership.org/syria-economic-monitor/notebooks/ais-analysis/README.html).

```{figure} ../reports/figures/trade-estimates-summer-latakia.png
---
align: center
---
Estimated imports and exports (tonnes) in Latakia based on AIS data.
```

```{figure} ../reports/figures/trade-estimates-summer-tartus.png
---
align: center
---
Estimated imports and exports (tonnes) in Tartus based on AIS data.
```

### Unique Vessels in Turkey and Syria

Additionally, we assessed the impact of the February earthquake, by looking at daily counts of unique vessels in selected ports that are geographically close to the epicenter.

```{figure} ../reports/figures/unique-vessels-2023.jpeg
---
align: center
---
Daily count of unique vessels in selected ports. 
```