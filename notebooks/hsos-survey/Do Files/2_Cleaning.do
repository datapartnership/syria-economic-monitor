********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Processing and cleaning
* Details: Codification of variables as needed for indicators.
* Author: Alejandra Quevedo (al.quevedo0420@gmail.com)(acardona@worldbank.org)
********************************************************************
clear

use "${output}\HSOS_clean"


*Community
encode community_code, gen(community_num)

gen id=1 if year==2021
replace id=2 if year==2022 & month==3
replace id=3 if year==2022 & month==4
replace id=4 if year==2022 & month==12
replace id=5 if year==2023 & month==3
replace id=6 if year==2023 & month==4

label define id 1 "Dec 2021" 2 "Mar 2022" 3 "Apr 2022" 4 "Dec 2022" 5 "Mar 2023" 6 "April 2023"
label values id id



*Variables of education
*In education, edit to match information from march 2023.
replace education_funct="Education services were functioning" if education_funct=="Education services were functioning in person"


replace education_funct="Education services were functioning" if education_funct=="Education services were functioning in person, Education services were functioning online"

replace education_funct="Education services were functioning" if education_funct=="Education services were functioning online, Education services were functioning in person"


*Variables of prices
*Currency prices, for rent and wages, create variables with all prices in USD.
gen price_rent_n=price_rent
replace price_rent_n="" if price_rent_n=="No Data" | price_rent=="NA - No renting in the assessed location"

gen RES_wage_unskilled_n=RES_wage_unskilled
replace RES_wage_unskilled_n="" if RES_wage_unskilled_n=="No Data" | RES_wage_unskilled_n=="NA" | RES_wage_unskilled_n=="NA - No residents in the assessed location"

gen IDP_wage_unskilled_n=IDP_wage_unskilled
replace IDP_wage_unskilled_n="" if IDP_wage_unskilled_n=="NA" | IDP_wage_unskilled_n=="NA - No IDPs in the assessed location"


destring price_rent_n, gen (price_rent_v) force
destring RES_wage_unskilled_n, gen(RES_wage_unskilled_v) force
destring IDP_wage_unskilled_n, gen(IDP_wage_unskilled_v) force

drop price_rent_n RES_wage_unskilled_n IDP_wage_unskilled_n

*****
*Exchange rate taken from the 15th of every month.
gen currency_rent_rate=.
replace currency_rent_rate=0.000398007 if year==2021 & month==12 & currency_rents=="Syrian pounds"
replace currency_rent_rate=0.000398129 if year==2022 & month==3 & currency_rents=="Syrian pounds"
replace currency_rent_rate=0.000398084 if year==2022 & month==12 & currency_rents=="Syrian pounds"
replace currency_rent_rate=0.000398005 if year==2023 & month==3 & currency_rents=="Syrian pounds"
replace currency_rent_rate=0.000398093 if year==2022 & month==4 & currency_rents=="Syrian pounds"
replace currency_rent_rate=0.000398006 if year==2023 & month==4 & currency_rents=="Syrian pounds"

replace currency_rent_rate=1 if currency_rents=="United States dollars"

replace currency_rent_rate=0.0694971 if year==2021 & month==12 & currency_rents=="Turkish lira"
replace currency_rent_rate=0.0674711 if year==2022 & month==3 & currency_rents=="Turkish lira"
replace currency_rent_rate=0.0536637 if year==2022 & month==12 & currency_rents=="Turkish lira"
replace currency_rent_rate=0.0526742 if year==2023 & month==3 & currency_rents=="Turkish lira"
replace currency_rent_rate=0.0683493 if year==2022 & month==4 & currency_rents=="Turkish lira"
replace currency_rent_rate=0.0516457 if year==2023 & month==4 & currency_rents=="Turkish lira"


*****
gen currency_IDPw_rate=.

replace currency_IDPw_rate=0.000398007 if year==2021 & month==12 & currency_wages_IDP=="Syrian pounds"
replace currency_IDPw_rate=0.000398129 if year==2022 & month==3 & currency_wages_IDP=="Syrian pounds"
replace currency_IDPw_rate=0.000398084 if year==2022 & month==12 & currency_wages_IDP=="Syrian pounds"
replace currency_IDPw_rate=0.000398005 if year==2023 & month==3 & currency_wages_IDP=="Syrian pounds"
replace currency_IDPw_rate=0.000398093 if year==2022 & month==4 & currency_wages_IDP=="Syrian pounds"
replace currency_IDPw_rate=0.000398006 if year==2023 & month==4 & currency_wages_IDP=="Syrian pounds"

replace currency_IDPw_rate=0.0694971 if year==2021 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate=0.0674711 if year==2022 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate=0.0536637 if year==2022 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate=0.0526742 if year==2023 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate=0.0683493 if year==2022 & month==4 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate=0.0516457 if year==2023 & month==4 & currency_wages_IDP=="Turkish lira"

*****
gen currency_RESw_rate=.

replace currency_RESw_rate=0.000398007 if year==2021 & month==12 & currency_wages_RES=="Syrian pounds"
replace currency_RESw_rate=0.000398129 if year==2022 & month==3 & currency_wages_RES=="Syrian pounds"
replace currency_RESw_rate=0.000398084 if year==2022 & month==12 & currency_wages_RES=="Syrian pounds"
replace currency_RESw_rate=0.000398005 if year==2023 & month==3 & currency_wages_RES=="Syrian pounds"
replace currency_RESw_rate=0.000398093 if year==2022 & month==4 & currency_wages_RES=="Syrian pounds"
replace currency_RESw_rate=0.000398006 if year==2023 & month==4 & currency_wages_RES=="Syrian pounds"

replace currency_RESw_rate=0.0694971 if year==2021 & month==12 & currency_wages_RES=="Turkish lira"
replace currency_RESw_rate=0.0674711 if year==2022 & month==3 & currency_wages_RES=="Turkish lira"
replace currency_RESw_rate=0.0536637 if year==2022 & month==12 & currency_wages_RES=="Turkish lira"
replace currency_RESw_rate=0.0526742 if year==2023 & month==3 & currency_wages_RES=="Turkish lira"
replace currency_RESw_rate=0.0683493 if year==2022 & month==4 & currency_wages_RES=="Turkish lira"
replace currency_RESw_rate=0.0516457 if year==2023 & month==4 & currency_wages_RES=="Turkish lira"

**********
gen price_rent_usd=price_rent_v*currency_rent_rate
gen RES_wage_unskilled_usd=RES_wage_unskilled_v*currency_RESw_rate
gen IDP_wage_unskilled_usd=IDP_wage_unskilled_v*currency_IDPw_rate

**********
*Currency rates for Syrian pounds
gen currency_rent_rate1=.

replace currency_rent_rate1=1 if currency_rents=="Syrian pounds"

replace currency_rent_rate1=2512.55 if currency_wages_IDP=="United States dollars"

replace currency_rent_rate1=174.613 if year==2021 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_rent_rate1=169.471 if year==2022 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_rent_rate1=134.805 if year==2022 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_rent_rate1=132.346 if year==2023 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_rent_rate1=171.692 if year==2022 & month==4 & currency_wages_IDP=="Turkish lira"
replace currency_rent_rate1=129.761 if year==2023 & month==4 & currency_wages_IDP=="Turkish lira"


gen currency_IDPw_rate1=.

replace currency_IDPw_rate1=1 if currency_wages_IDP=="Syrian pounds"

replace currency_IDPw_rate1=174.613 if year==2021 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate1=169.471 if year==2022 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate1=134.805 if year==2022 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate1=132.346 if year==2023 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate1=171.692 if year==2022 & month==4 & currency_wages_IDP=="Turkish lira"
replace currency_IDPw_rate1=129.761 if year==2023 & month==4 & currency_wages_IDP=="Turkish lira"

gen currency_RESw_rate1=.

replace currency_RESw_rate1=1 if currency_wages_IDP=="Syrian pounds"

replace currency_RESw_rate1=174.613 if year==2021 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_RESw_rate1=169.471 if year==2022 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_RESw_rate1=134.805 if year==2022 & month==12 & currency_wages_IDP=="Turkish lira"
replace currency_RESw_rate1=132.346 if year==2023 & month==3 & currency_wages_IDP=="Turkish lira"
replace currency_RESw_rate1=171.692 if year==2022 & month==4 & currency_wages_IDP=="Turkish lira"
replace currency_RESw_rate1=129.761 if year==2023 & month==4 & currency_wages_IDP=="Turkish lira"

*******
gen price_rent_sp=price_rent_v*currency_rent_rate1
gen RES_wage_unskilled_sp=RES_wage_unskilled_v*currency_RESw_rate1
gen IDP_wage_unskilled_sp=IDP_wage_unskilled_v*currency_IDPw_rate1


*******


*Reported Variables
*******Cleaning Yes/No
gen IDP_reported1=1 if IDP_reported=="Yes"
replace IDP_reported1=0 if IDP_reported=="No"

label define yesno 1 "Yes" 0 "No"

drop IDP_reported
rename IDP_reported1 IDP_reported
label values IDP_reported yesno

gen RES_reported1=1 if RES_reported=="Yes"
replace RES_reported1=0 if RES_reported=="No"
drop RES_reported
rename RES_reported1 RES_reported
label values RES_reported yesno

gen water_functioning1=1 if water_functioning=="Yes"
replace water_functioning1=0 if water_functioning=="No"
drop water_functioning
rename water_functioning1 water_functioning
label values water_functioning yesno

gen sewage_connect1=1 if sewage_connect=="Yes"
replace sewage_connect1=0 if sewage_connect=="No"
drop sewage_connect
rename sewage_connect1 sewage_connect
label values sewage_connect yesno

gen RES_humani_barr_noavai1=1 if RES_humani_barr_noavai=="Yes"
replace RES_humani_barr_noavai1=0 if RES_humani_barr_noavai=="No"
drop RES_humani_barr_noavai
rename RES_humani_barr_noavai1 RES_humani_barr_noavai
label values RES_humani_barr_noavai yesno

gen IDP_humani_barr_noavai1=1 if IDP_humani_barr_noavai=="Yes"
replace IDP_humani_barr_noavai1=0 if IDP_humani_barr_noavai=="No"
drop IDP_humani_barr_noavai
rename IDP_humani_barr_noavai1 IDP_humani_barr_noavai
label values IDP_humani_barr_noavai yesno

gen foodmark_access1=1 if foodmark_access=="Yes"
replace foodmark_access1=0 if foodmark_access=="No"
drop foodmark_access
rename foodmark_access1 foodmark_access
label values foodmark_access yesno

gen market_access1=1 if market_access=="Yes"
replace market_access1=0 if market_access=="No"
drop market_access
rename market_access1 market_access
label values market_access yesno

gen food_source_purchase_outcomm1=1 if food_source_purchase_outcomm=="Yes"
replace food_source_purchase_outcomm1=0 if food_source_purchase_outcomm=="No"
drop food_source_purchase_outcomm
rename food_source_purchase_outcomm1 food_source_purchase_outcomm
label values food_source_purchase_outcomm yes

gen health_access_inloc1=1 if health_access_inloc=="Yes"
replace health_access_inloc1=0 if health_access_inloc=="No"
drop health_access_inloc
rename health_access_inloc1 health_access_inloc
label values health_access_inloc yesno

gen health_access_near1=1 if health_access_near=="Yes"
replace health_access_near1=1 if health_access_near=="No"
drop health_access_near
rename health_access_near1 health_access_near
label values health_access_near yesno

*Humanitarian aid access variables

gen RES_humani_access_m=1 if RES_humani_access=="Yes"
replace RES_humani_access_m=0 if RES_humani_access=="No"

gen IDP_humani_access_m=1 if IDP_humani_access=="Yes"
replace IDP_humani_access_m=0 if IDP_humani_access=="No"


drop RES_humani_access IDP_humani_access
rename RES_humani_access_m RES_humani_access
rename IDP_humani_access_m IDP_humani_access

label values RES_humani_access yesno
label value IDP_humani_access yesno

*Education variables.
gen education_funct1=1 if education_funct=="Education services were functioning"
replace education_funct1=0 if education_funct=="Education services were not functioning"

drop education_funct
rename education_funct1 education_funct
label define educ 1 "Functioning" 0 "Not functioning"
label values education_funct educ

gen RES_edu_50=1 if RES_education_accessing=="None" | RES_education_accessing==" 1 to 25 percent" | RES_education_accessing=="26 to 50 percent"
replace RES_edu_50=0 if RES_education_accessing=="51 to 75 percent" | RES_education_accessing=="76 to 99 percent" | RES_education_accessing=="100 percent"

gen IDP_edu_50=1 if IDP_education_accessing=="None" | IDP_education_accessing==" 1 to 25 percent" | IDP_education_accessing=="26 to 50 percent"
replace IDP_edu_50=0 if IDP_education_accessing=="51 to 75 percent" | IDP_education_accessing=="76 to 99 percent" | IDP_education_accessing=="100 percent"

label define edu50 1 "Less than 50%" 0 "More than 50%"
label values RES_edu_50 edu50
label values IDP_edu_50 edu50

*Date variable
gen date = ym(year, month)
format %tm date


*Variables of RES & IDP living conditions
local liv IDP_liv_unfinished IDP_liv_damaged IDP_liv_tents IDP_liv_makeshift IDP_liv_overcrowded RES_liv_unfinished RES_liv_damaged RES_liv_overcrowded

foreach i of local liv {
	replace `i'="1 to 20 percent" if `i'=="1 to 10 percent" | `i'=="11 to 20 percent"
	replace `i'="21 to 40 percent" if `i'=="21 to 30 percent" | `i'=="31 to 40 percent"
	replace `i'="41 to 60 percent" if `i'=="41 to 50 percent" | `i'=="51 to 60 percent"
	replace `i'="61 to 80 percent" if `i'=="61 to 70 percent" | `i'=="71 to 80 percent"
	replace `i'="81 to 99 percent" if `i'=="81 to 90 percent" | `i'=="91 to 99 percent"
}


label define shelters 7 "None" 6 "1 to 20 percent" 5 "21 to 40 percent" 4 "41 to 60 percent" 3 "61 to 80 percent" 2 "81 to 99 percent" 1 "100 percent"

local shelt RES_liv_overcrowded IDP_liv_overcrowded SHE_no_damage SHE_minor_damage SHE_major_damage SHE_complete_damage

foreach i of local shelt {
	gen `i'1=7 if `i'=="None" | `i'=="0 percent"
replace `i'1=6 if `i'=="1 to 20 percent"
replace `i'1=5 if `i'=="21 to 40 percent"
replace `i'1=4 if `i'=="41 to 60 percent"
replace `i'1=3 if `i'=="61 to 80 percent"
replace `i'1=2 if `i'=="81 to 99 percent"
replace `i'1=1 if `i'=="100 percent"

label values `i'1 shelters
drop `i'
rename `i'1 `i'
}

*Indicator of shelters damage. 1 if they report any kind of damage in the shelters.
gen SHE_damage=1 if SHE_complete_damage!=7 | SHE_major_damage!=7 | SHE_minor_damage!=7
replace SHE_damage=0 if SHE_damage==.


*Indicators of RES & IDP living conditions
gen RES_liv_overcrowded60=1 if RES_liv_overcrowded==1 | RES_liv_overcrowded==2 |RES_liv_overcrowded==3
replace RES_liv_overcrowded60=0 if RES_liv_overcrowded==4 | RES_liv_overcrowded==5 | RES_liv_overcrowded==6 | RES_liv_overcrowded==7

gen IDP_liv_overcrowded60=1 if IDP_liv_overcrowded==1 | IDP_liv_overcrowded==2 |IDP_liv_overcrowded==3
replace IDP_liv_overcrowded60=0 if IDP_liv_overcrowded==4 | IDP_liv_overcrowded==5 | IDP_liv_overcrowded==6 | IDP_liv_overcrowded==7

gen SHE_minor_damage60=1 if SHE_minor_damage==1 | SHE_minor_damage==2 | SHE_minor_damage==3
replace SHE_minor_damage60=0 if SHE_minor_damage==4 | SHE_minor_damage==5 | SHE_minor_damage==6 | SHE_minor_damage==7


label define indi60 1 "More than 60%" 0 "Less than 60%"
label values RES_liv_overcrowded60 indi60
label values IDP_liv_overcrowded60 indi60
label values SHE_minor_damage60 indi60

*Indicator, days peer week water from the main network available

gen water_funct_7=1 if water_funct_days=="7"
replace water_funct_7=0 if water_funct_7==.
label define waterfunct 1 "All week" 0 "Not all week"
label values water_funct_7 waterfunct


*Variables of forms of humanitarian assistance
local access RES_humani_prov_shelter RES_humani_prov_health RES_humani_prov_nfi RES_humani_prov_electricity RES_humani_prov_food RES_humani_prov_agri RES_humani_prov_liveli RES_humani_prov_education RES_humani_prov_wash RES_humani_prov_winte RES_humani_prov_legal RES_humani_prov_gbv RES_humani_prov_cp RES_humani_prov_explo RES_humani_prov_mental RES_humani_prov_cash RES_humani_prov_voucher RES_humani_prov_other IDP_humani_prov_shelter IDP_humani_prov_health IDP_humani_prov_nfi IDP_humani_prov_electricity IDP_humani_prov_food IDP_humani_prov_agri IDP_humani_prov_liveli IDP_humani_prov_education IDP_humani_prov_wash IDP_humani_prov_winte IDP_humani_prov_legal IDP_humani_prov_gbv IDP_humani_prov_cp IDP_humani_prov_explo IDP_humani_prov_mental IDP_humani_prov_cash IDP_humani_prov_voucher RES_coping_sellittem RES_coping_sellprodu RES_coping_sellha RES_coping_childwork RES_coping_beg RES_coping_earlym RES_coping_forcedm RES_coping_borrow RES_coping_credit RES_coping_riskwork RES_coping_illegalwork RES_coping_skiprent RES_coping_saving RES_coping_school RES_coping_mig RES_coping_other RES_coping_nouse IDP_coping_sellittem IDP_coping_sellprodu IDP_coping_sellha IDP_coping_childwork IDP_coping_beg IDP_coping_earlym IDP_coping_forcedm IDP_coping_borrow IDP_coping_credit IDP_coping_riskwork IDP_coping_illegalwork IDP_coping_skiprent IDP_coping_saving IDP_coping_school IDP_coping_mig IDP_coping_other IDP_coping_nouse food_coping_reduce food_coping_skip food_coping_restrict food_coping_relying food_coping_buy food_coping_purchase food_coping_exchange food_coping_spend food_coping_other food_coping_no health_barr_nofacilities health_barr_rehab health_barr_afford health_barr_absence health_barr_lackppe health_barr_lacktransport health_barr_costtransport health_barr_trust health_barr_accessible health_barr_lackmed health_barr_overcrowded health_barr_femalestaff health_barr_privacy health_barr_specialized health_barr_ambulance health_barr_document health_barr_safety health_barr_safety2 health_barr_wsafety health_barr_wsafety2 health_barr_wallowed health_barr_stigma health_barr_other health_barr_no RES_edu_barr_cert RES_edu_barr_doc RES_edu_barr_transp RES_edu_barr_costt RES_edu_barr_unsafe RES_edu_barr_internet RES_edu_barr_elect RES_edu_barr_equip RES_edu_barr_costp RES_edu_barr_availa RES_edu_barr_language RES_edu_barr_work RES_edu_barr_marry RES_edu_barr_age RES_edu_barr_disabi RES_edu_barr_unable RES_edu_barr_uncom RES_edu_barr_health RES_edu_barr_social RES_edu_barr_girls RES_edu_barr_other IDP_edu_barr_cert IDP_edu_barr_doc IDP_edu_barr_transp IDP_edu_barr_costt IDP_edu_barr_unsafe IDP_edu_barr_internet IDP_edu_barr_elect IDP_edu_barr_equip IDP_edu_barr_costp IDP_edu_barr_availa IDP_edu_barr_language IDP_edu_barr_work IDP_edu_barr_marry IDP_edu_barr_age IDP_edu_barr_disabi IDP_edu_barr_unable IDP_edu_barr_uncom IDP_edu_barr_health IDP_edu_barr_social IDP_edu_barr_girls IDP_edu_barr_other


foreach i of local access {
	gen `i'_1=1 if `i'=="Yes"
	replace `i'_1=0 if `i'=="No"
	drop `i'
	rename `i'_1 `i'
}

*Variable of top priorities.
encode RES_priority, gen (RES_priority1)
encode RES_priority_2, gen (RES_priority2)
encode RES_priority_3, gen (RES_priority3)

encode IDP_priority, gen (IDP_priority1)
encode IDP_priority_2, gen (IDP_priority2)
encode IDP_priority_3, gen (IDP_priority3)

 /*
          1 Education
           2 Food
           3 Health
           4 Infrastructure
           5 Livelihoods
           6 NA - No residents in the assessed location
           7 NFIs
           8 Protection
           9 Shelter
          10 Summer  items
          11 WASH
          12 Winterisation
*/


forvalues i = 1/12 {
gen RES_priority1_`i'=1 if RES_priority1==`i'
replace RES_priority1_`i'=0 if RES_priority1_`i'==. & RES_priority1!=6
}

forvalues i = 1/12 {
gen RES_priority2_`i'=1 if RES_priority2==`i'
replace RES_priority2_`i'=0 if RES_priority2_`i'==. & RES_priority2!=6
}

forvalues i = 1/12 {
gen RES_priority3_`i'=1 if RES_priority3==`i'
replace RES_priority3_`i'=0 if RES_priority3_`i'==. & RES_priority3!=6
}

forvalues i = 1/12 {
gen IDP_priority1_`i'=1 if IDP_priority1==`i'
replace IDP_priority1_`i'=0 if IDP_priority1_`i'==. & IDP_priority1!=6
}

forvalues i = 1/12 {
gen IDP_priority2_`i'=1 if IDP_priority2==`i'
replace IDP_priority2_`i'=0 if IDP_priority2_`i'==. & IDP_priority2!=6
}

forvalues i = 1/12 {
gen IDP_priority3_`i'=1 if IDP_priority3==`i'
replace IDP_priority3_`i'=0 if IDP_priority3_`i'==. & IDP_priority3!=6
}

/*
gen RES_priority1_1=1 if RES_priority=="1"
replace RES_priority1_1=0 if RES_priority1_1==. & RES_priority1!="NA - No residents in the assessed location"

gen RES_priority_liveli=1 if RES_priority=="Livelihoods"
replace RES_priority_liveli=0 if RES_priority_liveli==. & RES_priority!="NA - No residents in the assessed location"

gen RES_priority_food=1 if RES_priority=="Food"
replace RES_priority_food=0 if RES_priority_food==. & RES_priority!="NA - No residents in the assessed location"

gen IDP_priority_food=1 if IDP_priority=="Food"
replace IDP_priority_food=0 if IDP_priority_food==. & IDP_priority!="NA - No IDPs in the assessed location"

gen IDP_priority_shelter=1 if IDP_priority=="Shelter"
replace IDP_priority_shelter=0 if IDP_priority_shelter==. & IDP_priority!="NA - No IDPs in the assessed location"
*/

*Creating, communities that do not receive humanitarian aid.
gen RES_humani_no=1 if RES_humani_access==0
gen IDP_humani_no=1 if IDP_humani_access==0


*Electricity source: main network
gen electricity_main=1 if electricity_source=="Main network"
replace  electricity_main=0 if electricity_main==. & electricity_source!="No Data"

label define elec 1 "Main network" 0 "Other"
label values electricity_main elec

*Electricity hours
gen electricity_8=1 if electricity_hours=="From 7 to 8 hours" | electricity_hours=="From 5 to 6 hours" | electricity_hours=="From 2 to 4 hours" | electricity_hours=="Less than 2 hours" | electricity_hours=="None"
replace electricity_8=0 if electricity_hours=="From 9 to 10 hours" | electricity_hours=="From 11 to 12 hours" | electricity_hours=="More than 12 hours"

label define elec8 1 "Less than 8" 0 "More than 0"
label values electricity_8 elec8

*Water source, private water trucing and piped water network.
gen water_piped=1 if water_source=="Piped water network"
replace water_piped=0 if water_piped==.

label define piped 1 "Piped water network" 0 "Other"
label values water_piped piped

gen water_private=1 if water_source=="Private water trucking conducted by private citizens"
replace water_private=0 if water_private==.

label define priv 1 "Private water trucking" 0 "Other"
label values water_private priv

*Label
/*local prov RES_humani_prov_food RES_humani_prov_health RES_humani_prov_cash IDP_humani_prov_food IDP_humani_prov_health IDP_humani_prov_cash RES_priority_liveli RES_priority_food IDP_priority_food IDP_priority_shelter food_source_purchase_outcomm


foreach i of local prov {
	label values `i' yesno
}
*/

save "${clean}\HSOS_analysis", replace
