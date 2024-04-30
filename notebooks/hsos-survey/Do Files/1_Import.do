********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Import of data, cleaning, append.
* Author: Alejandra Quevedo (al.quevedo0420@gmail.com)(acardona@worldbank.org)
********************************************************************

clear

/////////////////////////////////////////////////////////////////////////////////
////////////////////////DECEMBER/////////////////////////////////////////////////
***December, 2021***

local reg NWS NES
foreach i of local reg {

import excel "${original}\REACH_SYR_HSOS_Dataset_December2021_`i'", sheet("Dataset") firstrow clear


*Codebook created to easily identify the variables that I want to keep.*
*iecodebook template using "${codebooks}\keep_Dec21.xlsx"

keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CG CH CJ Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Wastheassessedlocationconnec Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor PK PL PM PN PO PP PQ PR PS PT Reportedcopingstrategiesthat TU TV TW TX TY TZ UA UB UC UD UE UF UG UH UI UJ Inwhatcurrencyaremostreside Estimateddailywageforunskill WN WO WP WQ WR WS WT WU WV WW WX WY WZ XA XB XC XD InwhatcurrencyaremostIDPda XF Werehouseholdsabletoaccessh ZA Educationservicesfunctioningi AEW AEX AEY Daysinpersoneducationservice Daysonlineeducationservicesw Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BLS BLT BLU BLV BLW BLX BLY BLZ BMA BMB BMC BMD BME BMF BMG BMH BMI Barrierstoaccessinghumanitari BMK BML BMM BMN BMO BMP BMQ BMR BMS WereIDPhouseholdsinthecommu BNL BNM BNN BNO BNP BNQ BNR BNS BNT BNU BNV BNW BNX BNY BNZ BOA BOB BOC BOD BOE BOF BOG BOH BOI BOJ BOK BOL BOM Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BRD BRE BRF Reportedhouseholdcopingstrate PV PW PX PY PZ QA QB QC QD QE Barrierstohealthcareaccessin AAE AAF AAG AAH AAI AAJ AAK AAL AAM AAN AAO AAP AAQ AAR AAS AAT AAU AAV AAW AAX AAY AAZ ABA ABB Barrierspreventingaccesstoed AGY AGZ AHA AHB AHC AHD AHE AHF AHG AHH AHI AHJ AHK AHL AHM AHN AHO AHP AHQ AHR AHS AIC AID AIE AIF AIG AIH AII AIJ AIK AIL AIM AIN AIO AIP AIQ AIR AIS AIT AIU AIV AIW AIX


*iecodebook template using "${codebooks}\cleaning_Dec21_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Dec21_v3.xlsx"

gen year=2021
gen month=12
gen region="`i'"

save "${output}\2021_December_`i'", replace
}

***December, 2022***
local reg NWS NES
foreach i of local reg {

import excel "${original}\REACH_SYR_HSOS_Dataset_December2022_`i'", sheet("Dataset") firstrow clear

*Codebook created to easily identify the variables that I want to keep.*
*iecodebook template using "${codebooks}\keep_Dec2022.xlsx"

keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CM CN CR Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Wastheassessedlocationconnec Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor QP QQ QR QS QT QU QV QW QX QY Reportedcopingstrategiesthat VD VE VF VG VH VI VJ VK VL VM VN VO VP VQ VR VS VT Inwhatcurrencyaremostreside Estimateddailywageforunskill XY XZ YA YB YC YD YE YF YG YH YI YJ YK YL YM YN YO YP InwhatcurrencyaremostIDPda YR Werehouseholdsabletoaccessh AAO Educationservicesfunctioningi AGO AGP AGQ Daysinpersoneducationservice Daysonlineeducationservicesw Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BOK BOL BOM BON BOO BOP BOQ BOR BOS BOT BOU BOV BOW BOX BOY BOZ BPA BPB Barrierstoaccessinghumanitari BPD BPE BPF BPG BPH BPI BPJ BPK BPL WereIDPhouseholdsinthecommu BQE BQF BQG BQH BQI BQJ BQK BQL BQM BQN BQO BQP BQQ BQR BQS BQT BQU BQV BQW BQX BQY BQZ BRA BRB BRC BRD BRE BRF BRG Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BTX BTY BTZ Reportedhouseholdcopingstrate RA RB RC RD RE RF RG RH RI RJ Barrierstohealthcareaccessin ABS ABT ABU ABV ABW ABX ABY ABZ ACA ACB ACC ACD ACE ACF ACG ACH ACI ACJ ACK ACL ACM ACN ACO ACP Barrierspreventingaccesstoed AIU AIV AIW AIX AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN AJO AJY AJZ AKA AKB AKC AKD AKE AKF AKG AKH AKI AKJ AKK AKL AKM AKN AKO AKP AKQ AKR AKS AKT


*iecodebook template using "${codebooks}\cleaning_Dec22_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Dec22_v3.xlsx"


gen year=2022
gen month=12
gen region="`i'"

save "${output}\2022_December_`i'", replace
}

/////////////////////////////////////////////////////////////////////////////////
////////////////////////MARCH///////////////////////////////////////////////////
***March, 2022***

local reg NWS NES
foreach i of local reg {
import excel "${original}\REACH_SYR_HSOS_Dataset_March2022_`i'.xlsx", sheet("Dataset") firstrow clear

*iecodebook template using "${codebooks}\keep_Mar22.xlsx"


keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CG CH CJ Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Wastheassessedlocationconnec Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor QE QF QG QH QI QJ QK QL QM QN Reportedcopingstrategiesthat UO UP UQ UR US UT UU UV UW UX UY UZ VA VB VC VD Inwhatcurrencyaremostreside Estimateddailywageforunskill XH XI XJ XK XL XM XN XO XP XQ XR XS XT XU XV XW XX InwhatcurrencyaremostIDPda XZ Werehouseholdsabletoaccessh ZV Educationservicesfunctioningi AFQ AFR AFS Daysinpersoneducationservice Daysonlineeducationservicesw Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BMM BMN BMO BMP BMQ BMR BMS BMT BMU BMV BMW BMX BMY BMZ BNA BNB BNC Barrierstoaccessinghumanitari BNE BNF BNG BNH BNI BNJ BNK BNL BNM WereIDPhouseholdsinthecommu BOF BOG BOH BOI BOJ BOK BOL BOM BON BOO BOP BOQ BOR BOS BOT BOU BOV BOW BOX BOY BOZ BPA BPB BPC BPD BPE BPF BPG Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BRX BRY BRZ Reportedhouseholdcopingstrate QP QQ QR QS QT QU QV QW QX QY Barrierstohealthcareaccessin AAY AAZ ABA ABB ABC ABD ABE ABF ABG ABH ABI ABJ ABK ABL ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV Barrierspreventingaccesstoed AHS AHT AHU AHV AHW AHX AHY AHZ AIA AIB AIC AID AIE AIF AIG AIH AII AIJ AIK AIL AIM AIW AIX AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN AJO AJP AJQ AJR

*iecodebook template using "${codebooks}\cleaning_Mar22_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Mar22_v3.xlsx"


gen year=2022
gen month=03
gen region="`i'"

save "${output}\2022_Mar_`i'", replace
}


***March, 2023***
***
*NWS

import excel "${original}\REACH_SYR_HSOS_Dataset_March2023_NWS", sheet("Dataset") firstrow clear

*Codebook created to easily identify the variables that I want to keep.
*iecodebook template using "${codebooks}\keep_Mar23_NWS.xlsx"
keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CN CO CR Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Istheassessedlocationconnect Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor QW QX QY QZ RA RB RC RD RE RF Reportedcopingstrategiesthat VJ VK VL VM VN VO VP VQ VR VS VT VU VV VW VX VY VZ Inwhatcurrencyaremostreside Estimateddailywageforunskill YD YE YF YG YH YI YJ YK YL YM YN YO YP YQ YR YS YT YU InwhatcurrencyaremostIDPda YW Werehouseholdsabletoaccessh AAN Educationservicesfunctioningi Dayseducationserviceswerefun Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BNZ BOA BOB BOC BOD BOE BOF BOG BOH BOI BOJ BOK BOL BOM BON BOO BOP BOQ Barrierstoaccessinghumanitari BOS BOT BOU BOV BOW BOX BOY BOZ BPA WereIDPhouseholdsinthecommu BPT BPU BPV BPW BPX BPY BPZ BQA BQB BQC BQD BQE BQF BQG BQH BQI BQJ BQK BQL BQM BQN BQO BQP BQQ BQR BQS BQT BQU BQV Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BTM BTN BTO Reportedhouseholdcopingstrate RH RI RJ RK RL RM RN RO RP RQ Barrierstohealthcareaccessin ABS ABT ABU ABV ABW ABX ABY ABZ ACA ACB ACC ACD ACE ACF ACG ACH ACI ACJ ACK ACL ACM ACN ACO ACP Barrierspreventingaccesstoed AIP AIQ AIR AIS AIT AIU AIV AIW AIX AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJQ AJR AJS AJT AJU AJV AJW AJX AJY AJZ AKA AKB AKC AKD AKE AKF AKG AKH AKI


*iecodebook template using "${codebooks}\cleaning_Mar23NWS_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Mar23NWS_v3.xlsx"

gen year=2023
gen month=03
gen region="NWS"

save "${output}\2023_March_NWS", replace

*NES

import excel "${original}\REACH_SYR_HSOS_Dataset_March2023_NES", sheet("Dataset") firstrow clear

*Codebook created to easily identify the variables that I want to keep.
*iecodebook template using "${codebooks}\keep_Mar23_NES.xlsx"

keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CG CH CJ Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Istheassessedlocationconnect Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor QE QF QG QH QI QJ QK QL QM QN Reportedcopingstrategiesthat UR US UT UU UV UW UX UY UZ VA VB VC VD VE VF VG VH Inwhatcurrencyaremostreside Estimateddailywageforunskill XL XM XN XO XP XQ XR XS XT XU XV XW XX XY XZ YA YB YC InwhatcurrencyaremostIDPda YE Werehouseholdsabletoaccessh ZV Educationservicesfunctioningi Dayseducationserviceswerefun Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BML BMM BMN BMO BMP BMQ BMR BMS BMT BMU BMV BMW BMX BMY BMZ BNA BNB BNC Barrierstoaccessinghumanitari BNE BNF BNG BNH BNI BNJ BNK BNL BNM WereIDPhouseholdsinthecommu BOF BOG BOH BOI BOJ BOK BOL BOM BON BOO BOP BOQ BOR BOS BOT BOU BOV BOW BOX BOY BOZ BPA BPB BPC BPD BPE BPF BPG BPH Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BRY BRZ BSA Reportedhouseholdcopingstrate QP QQ QR QS QT QU QV QW QX QY Barrierstohealthcareaccessin ABA ABB ABC ABD ABE ABF ABG ABH ABI ABJ ABK ABL ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV ABW ABX Barrierspreventingaccesstoed AHX AHY AHZ AIA AIB AIC AID AIE AIF AIG AIH AII AIJ AIK AIL AIM AIN AIO AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN AJO AJP AJQ



*iecodebook template using "${codebooks}\cleaning_Mar23NES_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Mar23NES_v3.xlsx"

gen year=2023
gen month=03
gen region="NES"

save "${output}\2023_March_NES", replace


/////////////////////////////////////////////////////////////////////////////////
////////////////////////APRIL/////////////////////////////////////////////////
*April 2022
local reg NWS NES
foreach i of local reg {

import excel "${original}\REACH_SYR_HSOS_Dataset_April2022_`i'", sheet("Dataset") firstrow clear

*iecodebook template using "${codebooks}\keep_Apr22.xlsx"

keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CG CH CJ Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Wastheassessedlocationconnec Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor PK PL PM PN PO PP PQ PR PS PT Reportedcopingstrategiesthat TU TV TW TX TY TZ UA UB UC UD UE UF UG UH UI UJ Inwhatcurrencyaremostreside Estimateddailywageforunskill WN WO WP WQ WR WS WT WU WV WW WX WY WZ  XA XB XC XD InwhatcurrencyaremostIDPda XF Werehouseholdsabletoaccessh ZA Educationservicesfunctioningi AEW AEX AEY Daysinpersoneducationservice Daysonlineeducationservicesw Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BLS BLT BLU BLV BLW BLX BLY BLZ BMA BMB BMC BMD BME BMF BMG BMH BMI Barrierstoaccessinghumanitari BMK BML BMM BMN BMO BMP BMQ BMR BMS WereIDPhouseholdsinthecommu BNL BNM BNN BNO BNP BNQ BNR BNS BNT BNU BNV BNW BNX BNY BNZ BOA BOB BOC BOD BOE BOF BOG BOH BOI BOJ BOK BOL BOM Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BRD BRE BRF Reportedhouseholdcopingstrate PV PW PX PY PZ QA QB QC QD QE Barrierstohealthcareaccessin AAE AAF AAG AAH AAI AAJ AAK AAL AAM AAN AAO AAP AAQ AAR AAS AAT AAU AAV AAW AAX AAY AAZ ABA ABB Barrierspreventingaccesstoed AGY AGZ AHA AHB AHC AHD AHE AHF AHG AHH AHI AHJ AHK AHL AHM AHN AHO AHP AHQ AHR AHS AIC AID AIE AIF AIG AIH AII AIJ AIK AIL AIM AIN AIO AIP AIQ AIR AIS AIT AIU AIV AIW AIX


*iecodebook template using "${codebooks}\cleaning_Apr22_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Apr22_v3.xlsx"

gen year=2022
gen month=04
gen region="`i'"

save "${output}\2022_April_`i'", replace
}

*April 2023


local reg NWS NES
foreach i of local reg {
import excel "${original}\REACH_SYR_HSOS_Dataset_April2023_`i'", sheet("Dataset") firstrow clear


*iecodebook template using "${codebooks}\keep_Apr23.xlsx"

keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode Residentsreportedinthecommun Returneesreportedinthecommun IDPsreportedinthecommunity ProportionofIDPslivinginunf ProportionofIDPslivingindam ProportionofIDPslivinginten ProportionofIDPslivinginmak ProportionofIDPslivinginove CN CO CR Proportionofshelterswithnod Proportionofshelterswithmino Proportionofshelterswithmajo Proportionofshelterscompletel Inwhatcurrencyaremostrents Averagepriceofrentfora2be Mostcommonsourceofelectricit Averagenumberofhourswithacc Mostcommonsourceofdrinkingw Istheassessedlocationconnect Averagenumberofdaysperweek Wastheassessedcommunityconne Werehouseholdsabletoaccessf Werehouseholdsabletoaccesst Mostcommonsourcesoffoodfor QC QD QE QF QG QH QI QJ QK QL Reportedcopingstrategiesthat UP UQ UR US UT UU UV UW UX UY UZ VA VB VC VD VE VF Inwhatcurrencyaremostreside Estimateddailywageforunskill XJ XK XL XM XN XO XP XQ XR XS XT XU XV XW XX XY XZ YA InwhatcurrencyaremostIDPda YC Werehouseholdsabletoaccessh ZT Educationservicesfunctioningi Dayseducationserviceswerefun Percentageofresidentschoolag PercentageofIDPschoolagedch Wereresidenthouseholdsinthe Humanitarianassistanceprovided BNF BNG BNH BNI BNJ BNK BNL BNM BNN BNO BNP BNQ BNR BNS BNT BNU BNV BNW Barrierstoaccessinghumanitari BNY BNZ BOA BOB BOC BOD BOE BOF BOG WereIDPhouseholdsinthecommu BOZ BPA BPB BPC BPD BPE BPF BPG BPH BPI BPJ BPK BPL BPM BPN BPO BPP BPQ BPR BPS BPT BPU BPV BPW BPX BPY BPZ BQA BQB Whatwasthetoppriorityneedf Whatwasthesecondtoppriority Whatwasthethirdtoppriority BSS BST BSU Reportedhouseholdcopingstrate QN QO QP QQ QR QS QT QU QV QW Barrierstohealthcareaccessin AAY AAZ ABA ABB ABC ABD ABE ABF ABG ABH ABI ABJ ABK ABL ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV Barrierspreventingaccesstoed AHV AHW AHX AHY AHZ AIA AIB AIC AID AIE AIF AIG AIH AII AIJ AIK AIL AIM AIW AIX AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN AJO


*iecodebook template using "${codebooks}\cleaning_Apr23_v3.xlsx"
iecodebook apply using "${codebooks}\cleaning_Apr23_v3.xlsx"

gen year=2023
gen month=04
gen region="`i'"

save "${output}\2023_April_`i'", replace
}
***************
***************
*Append of regions.
use "${output}\2022_December_NES"
append using "${output}\2022_December_NWS"
save "${output}\2022_December_HSOS", replace

***************
use "${output}\2022_Mar_NWS"
append using "${output}\2022_Mar_NES"
save "${output}\2022_March_HSOS", replace

***************
use "${output}\2021_December_NWS"
append using "${output}\2021_December_NES"
save "${output}\2021_December_HSOS", replace

***************
use "${output}\2023_March_NWS"
append using "${output}\2023_March_NES"
save "${output}\2023_March_HSOS", replace

***************
use "${output}\2023_April_NWS"
append using "${output}\2023_April_NES"
save "${output}\2023_April_HSOS", replace

***************
use "${output}\2022_April_NWS"
append using "${output}\2022_April_NES"
save "${output}\2022_April_HSOS", replace



**
use "${output}\2022_December_HSOS"

append using "${output}\2022_March_HSOS"
append using "${output}\2021_December_HSOS"
append using "${output}\2023_March_HSOS"
append using "${output}\2023_April_HSOS"
append using "${output}\2022_April_HSOS"


*****Clean to only have the panel data.
*To see which variables are repeated across de 4 months of interest.
duplicates tag community_code, generate(panel_code)
*When panel_code=3, it means the observations has 3 duplicates and it is repeated in the 4 months.
drop if panel_code!=5
*This leave us with 1,491 community for which we have information.

save "${output}\HSOS_clean", replace


********
******** Merge with intensity dataset.
import delimited "${original}\syria_adm4_earthquake_intensity.csv", clear
*This is the dataset found in the share file.

rename adm4_en community
rename adm3_en subdistrict


duplicates tag community subdistrict, gen(dup)
**There is one observation repeated that affects the merge that I will conduct later. It is the community Suran, subdistrict Suran which is repeated twice. It is not in our data so I delete it.

drop if dup==1

save "${output}\intensity_clean", replace

********
import excel "${original}\IntensityAoC_ADM4_v12.xlsx", sheet("Sheet1") firstrow clear
*This dataset is the one that contains also info on the AoC

rename ADM4_PCODE community_code

save "${output}\Intensity_aoc_clean", replace

***
use "${output}\HSOS_clean"

*Merging w latest intensity data
merge m:1 community subdistrict using "${output}\intensity_clean"

drop if _merge==2
drop v1 adm1_en adm2_en dup
rename category_max_feb06 intensity
label var intensity "Category of earthquake intensity feb 6"
drop _merge

*Merging w previous intensity dataset to have info on actor type
merge m:1 community_code using "${output}\Intensity_aoc_clean"

drop if _merge==2

drop PP_NAME_EN PP_PCODE PPClassNum PPClassTit ADM4_EN ADM3_EN ADM3_PCODE ADM2_EN ADM2_PCODE ADM1_EN ADM1_PCODE ADM0_EN ADM0_PCODE mi pga pgv Population _merge

**************
order year month
drop panel_code

save "${output}\HSOS_clean", replace
