********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Indicators 
* Details: Bar graphs
* Author: Alejandra Quevedo (al.quevedo0420@gmail.com)(acardona@worldbank.org)
********************************************************************
clear

set scheme gg_tableau


////NWS and NES
use "${clean}\HSOS_analysis"

gen treated_3=2 if intensity=="Very Strong" | intensity=="Strong" | intensity=="Severe"
replace treated_3=1 if intensity=="Moderate"
replace treated_3=0 if intensity=="Light"

label define treatment 0 "Light" 1 "Moderate" 2 "Strong/Very Strong"
label values treated_3 treatment

drop if treated_3==.
*This generates a sample of 1426 for each month

*Count of variables by treatment. 
gen freq=1
egen totalc=total(freq), by (id treated_3)


*Dummy variables
local varg IDP_reported RES_liv_overcrowded60 IDP_liv_overcrowded60 SHE_minor_damage60 RES_humani_access IDP_humani_access RES_humani_barr_noavai IDP_humani_barr_noavai electricity_main electricity_8 water_piped water_private foodmark_access market_access food_source_purchase_outcomm health_access_inloc education_funct RES_edu_50 IDP_edu_50 SHE_damage RES_humani_prov_shelter RES_humani_prov_health RES_humani_prov_nfi RES_humani_prov_electricity RES_humani_prov_food RES_humani_prov_agri RES_humani_prov_liveli RES_humani_prov_education RES_humani_prov_wash RES_humani_prov_winte RES_humani_prov_legal RES_humani_prov_gbv RES_humani_prov_cp RES_humani_prov_explo RES_humani_prov_mental RES_humani_prov_cash RES_humani_prov_voucher IDP_humani_prov_shelter IDP_humani_prov_health IDP_humani_prov_nfi IDP_humani_prov_electricity IDP_humani_prov_food IDP_humani_prov_agri IDP_humani_prov_liveli IDP_humani_prov_education IDP_humani_prov_wash IDP_humani_prov_winte IDP_humani_prov_legal IDP_humani_prov_gbv IDP_humani_prov_cp IDP_humani_prov_explo IDP_humani_prov_mental IDP_humani_prov_cash IDP_humani_prov_voucher RES_coping_sellittem RES_coping_sellprodu RES_coping_sellha RES_coping_childwork RES_coping_beg RES_coping_earlym RES_coping_forcedm RES_coping_borrow RES_coping_credit RES_coping_riskwork RES_coping_illegalwork RES_coping_skiprent RES_coping_saving RES_coping_school RES_coping_mig RES_coping_other RES_coping_nouse IDP_coping_sellittem IDP_coping_sellprodu IDP_coping_sellha IDP_coping_childwork IDP_coping_beg IDP_coping_earlym IDP_coping_forcedm IDP_coping_borrow IDP_coping_credit IDP_coping_riskwork IDP_coping_illegalwork IDP_coping_skiprent IDP_coping_saving IDP_coping_school IDP_coping_mig IDP_coping_other IDP_coping_nouse sewage_connect water_funct_7 IDP_priority1_1 IDP_priority1_2 IDP_priority1_3 IDP_priority1_4 IDP_priority1_5 IDP_priority1_6 IDP_priority1_7 IDP_priority1_8 IDP_priority1_9 IDP_priority1_10 IDP_priority1_11 IDP_priority1_12 IDP_priority2_1 IDP_priority2_2 IDP_priority2_3 IDP_priority2_4 IDP_priority2_5 IDP_priority2_6 IDP_priority2_7 IDP_priority2_8 IDP_priority2_9 IDP_priority2_10 IDP_priority2_11 IDP_priority2_12 IDP_priority3_1 IDP_priority3_2 IDP_priority3_3 IDP_priority3_4 IDP_priority3_5 IDP_priority3_6 IDP_priority3_7 IDP_priority3_8 IDP_priority3_9 IDP_priority3_10 IDP_priority3_11 IDP_priority3_12 RES_priority1_1 RES_priority1_2 RES_priority1_3 RES_priority1_4 RES_priority1_5 RES_priority1_6 RES_priority1_7 RES_priority1_8 RES_priority1_9 RES_priority1_10 RES_priority1_11 RES_priority1_12 RES_priority2_1 RES_priority2_2 RES_priority2_3 RES_priority2_4 RES_priority2_5 RES_priority2_6 RES_priority2_7 RES_priority2_8 RES_priority2_9 RES_priority2_10 RES_priority2_11 RES_priority2_12 RES_priority3_1 RES_priority3_2 RES_priority3_3 RES_priority3_4 RES_priority3_5 RES_priority3_6 RES_priority3_7 RES_priority3_8 RES_priority3_9 RES_priority3_10 RES_priority3_11 RES_priority3_12



foreach i of local varg {
	egen `i'p=total(`i'), by (id treated_3)
	gen `i'c=`i'p/totalc*100
}

*Continous var
local vard  price_rent_usd RES_wage_unskilled_usd IDP_wage_unskilled_usd
 
foreach i of local vard {
	egen `i'c=mean(`i'), by(id treated_3)
}

**Produced dataset for graphs

collapse IDP_reportedc	RES_liv_overcrowded60c	IDP_liv_overcrowded60c	SHE_minor_damage60c	RES_humani_accessc	IDP_humani_accessc	RES_humani_barr_noavaic	IDP_humani_barr_noavaic	electricity_mainc	electricity_8c	water_pipedc	water_privatec	foodmark_accessc	market_accessc	food_source_purchase_outcommc	health_access_inlocc	education_functc	RES_edu_50c	IDP_edu_50c	SHE_damagec	RES_humani_prov_shelterc	RES_humani_prov_healthc	RES_humani_prov_nfic	RES_humani_prov_electricityc	RES_humani_prov_foodc	RES_humani_prov_agric	RES_humani_prov_livelic	RES_humani_prov_educationc	RES_humani_prov_washc	RES_humani_prov_wintec	RES_humani_prov_legalc	RES_humani_prov_gbvc	RES_humani_prov_cpc	RES_humani_prov_exploc	RES_humani_prov_mentalc	RES_humani_prov_cashc	RES_humani_prov_voucherc	IDP_humani_prov_shelterc	IDP_humani_prov_healthc	IDP_humani_prov_nfic	IDP_humani_prov_electricityc	IDP_humani_prov_foodc	IDP_humani_prov_agric	IDP_humani_prov_livelic	IDP_humani_prov_educationc	IDP_humani_prov_washc	IDP_humani_prov_wintec	IDP_humani_prov_legalc	IDP_humani_prov_gbvc	IDP_humani_prov_cpc	IDP_humani_prov_exploc	IDP_humani_prov_mentalc	IDP_humani_prov_cashc	IDP_humani_prov_voucherc	RES_coping_sellittemc	RES_coping_sellproduc	RES_coping_sellhac	RES_coping_childworkc	RES_coping_begc	RES_coping_earlymc	RES_coping_forcedmc	RES_coping_borrowc	RES_coping_creditc	RES_coping_riskworkc	RES_coping_illegalworkc	RES_coping_skiprentc	RES_coping_savingc	RES_coping_schoolc	RES_coping_migc	RES_coping_otherc	RES_coping_nousec	IDP_coping_sellittemc	IDP_coping_sellproduc	IDP_coping_sellhac	IDP_coping_childworkc	IDP_coping_begc	IDP_coping_earlymc	IDP_coping_forcedmc	IDP_coping_borrowc	IDP_coping_creditc	IDP_coping_riskworkc	IDP_coping_illegalworkc	IDP_coping_skiprentc	IDP_coping_savingc	IDP_coping_schoolc	IDP_coping_migc	IDP_coping_otherc	IDP_coping_nousec	sewage_connectc	water_funct_7c	IDP_priority1_1c	IDP_priority1_2c	IDP_priority1_3c	IDP_priority1_4c	IDP_priority1_5c	IDP_priority1_6c	IDP_priority1_7c	IDP_priority1_8c	IDP_priority1_9c	IDP_priority1_10c	IDP_priority1_11c	IDP_priority1_12c	IDP_priority2_1c	IDP_priority2_2c	IDP_priority2_3c	IDP_priority2_4c	IDP_priority2_5c	IDP_priority2_6c	IDP_priority2_7c	IDP_priority2_8c	IDP_priority2_9c	IDP_priority2_10c	IDP_priority2_11c	IDP_priority2_12c	IDP_priority3_1c	IDP_priority3_2c	IDP_priority3_3c	IDP_priority3_4c	IDP_priority3_5c	IDP_priority3_6c	IDP_priority3_7c	IDP_priority3_8c	IDP_priority3_9c	IDP_priority3_10c	IDP_priority3_11c	IDP_priority3_12c	RES_priority1_1c	RES_priority1_2c	RES_priority1_3c	RES_priority1_4c	RES_priority1_5c	RES_priority1_6c	RES_priority1_7c	RES_priority1_8c	RES_priority1_9c	RES_priority1_10c	RES_priority1_11c	RES_priority1_12c	RES_priority2_1c	RES_priority2_2c	RES_priority2_3c	RES_priority2_4c	RES_priority2_5c	RES_priority2_6c	RES_priority2_7c	RES_priority2_8c	RES_priority2_9c	RES_priority2_10c	RES_priority2_11c	RES_priority2_12c	RES_priority3_1c	RES_priority3_2c	RES_priority3_3c	RES_priority3_4c	RES_priority3_5c	RES_priority3_6c	RES_priority3_7c	RES_priority3_8c	RES_priority3_9c	RES_priority3_10c	RES_priority3_11c	RES_priority3_12c price_rent_usdc RES_wage_unskilled_usdc IDP_wage_unskilled_usdc , by (id treated_3)

rename RES_humani_prov_electricityc RES_humani_prov_elec 
rename RES_humani_prov_educationc RES_humani_prov_edu

*iecodebook template using "${codebooks}\Graficas"
iecodebook apply using "${codebooks}\Graficas"


rename IDP_humani_prov_electricityc IDP_humani_prov_elec 
rename IDP_humani_prov_educationc IDP_humani_prov_edu

betterbar RES_humani_prov_shelterc RES_humani_prov_healthc RES_humani_prov_nfic RES_humani_prov_elec RES_humani_prov_foodc RES_humani_prov_agric RES_humani_prov_livelic RES_humani_prov_edu RES_humani_prov_washc RES_humani_prov_wintec RES_humani_prov_legalc RES_humani_prov_gbvc RES_humani_prov_cpc RES_humani_prov_exploc RES_humani_prov_mentalc RES_humani_prov_cashc RES_humani_prov_voucherc, over(id) ///
	title ("% of communities receiving each type of humanitarian aid: residents", size (small)) ///
	xtitle("Percentage of communities")
	
graph export "${figures}\Fig HA RES.png", as(png) name("Graph") replace
	
	
betterbar IDP_humani_prov_shelterc IDP_humani_prov_healthc IDP_humani_prov_nfic IDP_humani_prov_elec IDP_humani_prov_foodc IDP_humani_prov_agric IDP_humani_prov_livelic IDP_humani_prov_edu IDP_humani_prov_washc IDP_humani_prov_wintec IDP_humani_prov_legalc IDP_humani_prov_gbvc IDP_humani_prov_cpc IDP_humani_prov_exploc IDP_humani_prov_mentalc IDP_humani_prov_cashc IDP_humani_prov_voucherc, over(id) ///
	title ("% of communities receiving each type of humanitarian aid: IDP", size (small)) ///
	xtitle("Percentage of communities")
	
graph export "${figures}\Fig HA IDP.png", as(png) name("Graph") replace


betterbar RES_coping_sellittemc RES_coping_sellproduc RES_coping_sellhac RES_coping_childworkc RES_coping_begc RES_coping_earlymc RES_coping_forcedmc RES_coping_borrowc RES_coping_creditc RES_coping_riskworkc RES_coping_illegalworkc RES_coping_skiprentc RES_coping_savingc RES_coping_schoolc RES_coping_migc, over(id) ///
	title ("% of communities per coping strategies: Residents", size (small)) ///
	xtitle("Percentage of communities")
	
graph export "${figures}\Fig coping RES.png", as(png) name("Graph") replace



betterbar IDP_coping_sellittemc IDP_coping_sellproduc IDP_coping_sellhac IDP_coping_childworkc IDP_coping_begc IDP_coping_earlymc IDP_coping_forcedmc IDP_coping_borrowc IDP_coping_creditc IDP_coping_riskworkc IDP_coping_illegalworkc IDP_coping_skiprentc IDP_coping_savingc IDP_coping_schoolc IDP_coping_migc, over(id) ///
	title ("% of communities per coping strategies: IDP", size (small)) ///
	xtitle("Percentage of communities") xlabel(0 (20) 100)
	
graph export "${figures}\Fig coping IDP.png", as(png) name("Graph") replace


