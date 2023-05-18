# Humanitarian Assistance Survey Data


## Data

We use data from the Humanitarian Situation Overview Survey (HSOS) conducted by REACH. REACH is a joint initiative of IMPACT Initiatives, ACTED and the United Nations Institute for Training and Research - Operational Satellite Applications Programme (UNITAR-UNOSAT). The HSOS is collected monthly in Northeast Syria (NES) and Northwest Syria (NWS). The survey uses key informant interviews to collect data at the community (admin4) level. The panel used for the analysis includes 1,426 communities (371 in NWS and 1246 in NES) which are included in all rounds of data collection.

The HSOS includes information on community situations and needs relating to shelter, electricity, water sanitation and hygiene (WASH), food security, livelihoods, health, education, humanitarian assistance, and priority needs. HSOS has disaggregated information on the different conditions and needs of residents and internally displaced persons (IDPs).

Data for the analysis can be downloaded from [Syria Humanitarian Situation Overview Survey](https://reach-info.org/syr/hsos/).


## Methodology

In the analysis, we look at trends in the data before and after the earthquake, and whether those trends differ depending on severity of exposure to the earthquake. We use data from December 2022 as the most recent data before the earthquake and April 2023 as the first dataset after the earthquake. Note that we do not include data from January 2023 as it was collected for NWS only, and we do not include data from February 2023 as it was collected during the time of the earthquake.

We compare outcomes for communities severely impacted by the earthquake before/after the earthquake compared to communities moderately affected or lightly affected. We additionally compare the trends observed before/after the earthquake to the trends for the same three subsets of communities over the same period of time one year earlier. Specifically, we measure trends from December 2022 to March/April 2023, and compare those to trends from December 2021 to March/April 2022.

The earthquake exposure measure uses the Modified Mercalli Intensity Scale (mmi). From this we derive three groups of communities: light earthquake intensity, moderate intensity, and strong or very strong intensity.


## Implementation

Code to replicate the analysis can be found [ADD URL TO CODE](http://ADDGITHUBURL).

The main script ([ADD MAIN SCRIPT LINK.do](http://ADDGITHUBURL) loads all packages and runs all scripts for the analysis. The script for constructing the indicators can be found [ADD INDICATOR SCRIPT LINK](https://ADDGITHUBURL)), and the script to produce the graphs can be found [ADD GRAPHS SCRIPT LINK](https://ADDGITHUBURL).



## Findings

### Humanitarian Assistance
#### Access to humanitarian assistance
![IDP access](humani_access_IDP_c.png) | ![resident access](humani_access_RES_c.png)

#### Received assistance in form of cash
![IDP access](humani_prov_cash_IDP_c.png) | ![resident access](humani_prov_cash_RES_c.png)

#### Received assistance in form of food voucher
![IDP access](humani_prov_voucher_IDP_c.png) | ![RES access](humani_prov_voucher_RES_c.png)

#### Community did not have access to humanitarian aid
![IDP access](humani_barr_noavai_IDP_c.png) | ![RES access](humani_barr_noavai_RES_c.png)


### Welfare of IDP population
#### Top priority need is food
![IDP access](priority1_2_IDP_c.png) ![RES access](priority1_2_RES_c.png)

#### Top priority need is shelter
![IDP access](priority1_9_IDP_c.png) ![RES access](priority1_9_RES_c.png)

#### rent
![all communities](welfare_price_rent_usdc.png)

#### wage for unskilled labor
![IDP wage](welfare_wage_unskilled_usd_IDP_c.png) ![RES wage](welfare_wage_unskilled_usd_RES_c.png)

### Access to Services

#### Access to electricity
![electricity](access_electricity.png)

#### Access to education
![education](access_education.png)

## Limitations
The categorical definition of exposure to the earthquake: light, moderate, or strong intensity is highly geographically correlated within the HSOS sample. Of the 346 communities in NWS, 331 were affected strongly by the earthquake and the remaining 15 were affected moderately. In NES, in contrast, only 45 communities were strongly affected, 625 were moderately affected, and 410 were lightly affected. This is to say, nearly all strongly affected communities are in NWS and all lightly affected communities are in NES. NES and NWS differ in important observable and unobservable ways - such as the controlling regime, which limits the conclusions that can be drawn from the data.


## Next Steps
Given the limited variation in the measure of earthquake intensity, the first next step will be to explore distance from the epicenter as a more continuous measure which may be less correlated with other underlying conditions (such as soil characteristics). If we are able to establish parallel trends prior to the earthquake, a difference-in-difference strategy would be appropriate.
Longer-term, a larger survey sample, ideally nationally-representative  would all for more robust analysis.
