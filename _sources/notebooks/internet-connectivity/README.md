# Internet Connectivity Post Earthquake

To detect changes in network connectivity, two datasets are used - Ookla's Speedtest Intelligence dataset and Ookla's Mobile Coverage Scan dataset (**forthcoming**). These datasets were provided by [Ookla](https://www.ookla.com/ookla-for-good) through the proposal [Syria Rapid Damage Needs Assessment](https://portal.datapartnership.org/readableproposal/427) of the [Development Data Partnership](https://datapartnership.org).

## Data

The Ookla Speedtest connectivity dataset relies on user-generated speedtest information. Everytime a users conducts a speedtest on their laptop or mobile phone using fixed or broadband internet connections, it is recorded along with the latitude and longistude of the test, the ISP provider of the user. This data is then processed to generate indicators such as number of users who conducted the test, download speed, upload speed and latency.

## Methodology

Detailed information about the methodology and sampling used for Ookla Speedtest data extracts can be found [here](https://worldbankgroup.sharepoint.com.mcas.ms/teams/DevelopmentDataPartnershipCommunity-WBGroup/Shared%20Documents/Forms/AllItems.aspx?csf=1&web=1&e=Yvwh8r&cid=fccdf23e%2D94d5%2D48bf%2Db75d%2D0af291138bde&FolderCTID=0x012000CFAB9FF0F938A64EBB297E7E16BDFCFD&id=%2Fteams%2FDevelopmentDataPartnershipCommunity%2DWBGroup%2FShared%20Documents%2FProjects%2FData%20Lab%2FTurkiye%20Earthquake%20Impact%2FData%2Fookla%5Fspeedtest%2FSpeedtest%5FTest%5FMethodology%5Fv1%2E8%5F2023%2D01%2D01%2Epdf&viewid=80cdadb3%2D8bb3%2D47ae%2D8b18%2Dc1dd89c373c5&parent=%2Fteams%2FDevelopmentDataPartnershipCommunity%2DWBGroup%2FShared%20Documents%2FProjects%2FData%20Lab%2FTurkiye%20Earthquake%20Impact%2FData%2Fookla%5Fspeedtest)

## Implementation

Once the data was obtained from the Ookla Speedtest portal, the point data were transformed to align with the shapefiles provided by UNOCHA. More details can be found in the attached notebook.

## Limitations

The limitation of Ookla's Speedtest connectivity relies on user-generated tests. Although the average number of users who take a test remain relatively consistent per month, it is subject to fluctuation. The dataset also does not contain information about the same latitude and longitude consistently. However, given aggregated data is used (at admin 1 or admin 2 levels), the findings can still be useful.

## Next Steps

