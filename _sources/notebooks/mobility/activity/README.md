# Estimating Activity based on Mobility Data

Less movement typically means less economic activity. Understanding where and when population movement occurs can help inform disaster response and public policy, especially during crises.

Similarly to [COVID-19 Community Mobility Reports](https://www.google.com/covid19/mobility/), [Facebook Population During Crisis](https://dataforgood.facebook.com/dfg/tools/facebook-population-maps) and [Mapbox Movement Data](https://www.mapbox.com/movement-data), we generate a series of crisis-relevant metrics, including the sampled baseline population, **percent** and **z-score** changes in population. The metrics are calculated by counting devices of a mobility data panel in each tile and at each time period and comparing to a baseline period.

The following map shows the **z-score** on each tile for each time period. The **z-score** shows whether the change in population for that area is statistically different from the baseline period.

<iframe width="100%" height="500px" src="https://studio.foursquare.com/public/55af1cba-9659-4f10-811b-f7f08dfe2ed8/embed" frameborder="0" allowfullscreen></iframe>

```{tip}
[Click to see it on Foursquare Studio](https://studio.foursquare.com/public/55af1cba-9659-4f10-811b-f7f08dfe2ed8)
```

## Methodology

```{note}
See [methodological notes](https://datapartnership.org/turkiye-earthquake-impact/notebooks/mobility/README.html) for additional details. The results are obtained in conjunction with the [Support to Türkiye Earthquake Impact Analysis](https://datapartnership.org/turkiye-earthquake-impact).
```

## Limitations

The methodology presented is an investigative pilot aiming to shed light on the economic situation in Syria and Türkiye leveraging alternative data, when confront with the absence of traditional data and methods.

```{caution}
In summary, beyond standing-by peer-review, the limitations can be summarized in the following.

- The methodology relies on private intent data in the form of mobilily data. In other words, the input data was not produced or collected to analyze the population of interest or address the research question as its primary goal but repurposed for the public good. The benefits and caveats when using private intent data have been extensively discussed in the [World Development Report 2021](https://wdr2021.worldbank.org) {cite}`WorldBank2021WorldDevelopmentReport`.

- On the one hand, the mobility data panel is spatially and temporally granular and readily available, on the other hand it is created as a convenience sampling which constitutes an important source of bias. The panel composition is not entirely known and susceptible to change, the data collection and the composition of the mobility data panel cannot be controlled.

- In summary, the results cannot be interpreted to generalize the entirety of population movement but can potentially provide information on movement panels to inform Syrian economic situation, considering time constraints and the scarcity of traditional data sources in the context of Syria.
```
