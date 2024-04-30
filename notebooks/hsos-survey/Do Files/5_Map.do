********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Maps
* Autor: Alejandra Quevedo (al.quevedo0420@gmail.com)(acardona@worldbank.org)
********************************************************************
clear

*April 2023
local reg NWS NES
foreach i of local reg {
import excel "${original}\REACH_SYR_HSOS_Dataset_April2023_`i'", sheet("Dataset") firstrow clear


keep Governorate Governoratepcode District Districtpcode Subdistrict Subdistrictpcode Community Communitypcode IDPsreportedinthecommunity IDPsdisplacedincommunitybeca


gen year=2023
gen month=04
gen region="`i'"

save "${output}\2023_April_`i'_1", replace
}


use "${output}\2023_April_NWS_1"
append using "${output}\2023_April_NES_1"
save "${output}\2023_April_HSOS_1", replace

*
cd "${maps}"

spshape2dta "${maps}\Admin 4\syr_pplp_adm4_unocha_20210113.shp", replace saving(syria4)

use "syria4"
duplicates tag ADM4_PCODE, gen(duplicates)
drop if duplicates!=0

save "syria4", replace

**

use "${output}\2023_April_HSOS_1"



local access IDPsreportedinthecommunity IDPsdisplacedincommunitybeca

foreach i of local access {
	gen `i'_1=1 if `i'=="Yes"
	replace `i'_1=0 if `i'=="No"
	drop `i'
	rename `i'_1 `i'
}

rename IDPsdisplacedincommunitybeca IDPs_new

label define new 0 "No displaced IDPs by earthquake" 1 "Displaced IDPs by earthquake"

label values IDPs_new new

save "HSOS_syria4", replace

**
*Aggregate IDPs_new


egen IDPs_new3= total(IDPs_new), by (Subdistrictpcode)


gen count=1

egen count3= total(count), by(Subdistrictpcode)

gen IDPs_newp=IDPs_new3/count3*100

gen catIDPs_new=.
replace catIDPs_new=1 if IDPs_newp==0
replace catIDPs_new=2 if IDPs_newp>0 & IDPs_newp<25
replace catIDPs_new=3 if IDPs_newp>=25 & IDPs_newp<50
replace catIDPs_new=4 if IDPs_newp>=50 & IDPs_newp<75
replace catIDPs_new=5 if IDPs_newp>=75

label define cat 1 "0%" 2 "1% - 24%" 3 "25% - 49%" 4 "50% - 74%" 5 "75% - 100%"
label values catIDPs_new cat


rename Subdistrictpcode ADM3_PCODE

collapse catIDPs_new, by(region ADM3_PCODE)

label values catIDPs_new cat


spshape2dta "${maps}\Admin 3\syr_admbnda_adm3_uncs_unocha_20201217-polygon.shp", replace saving(syria3)

merge 1:m ADM3_PCODE using "syria3", keepusing(_ID)


spmap catIDPs_new using syria3_shp, id(_ID) clm(u) legend(pos(3)) fcolor(Reds) ndo(gs10) legend(title("% of communities where KIs" "reported that residents are" "displaced within their own" "community?", size(1.6) justification(right)))


graph export "${figures}\Map_IDPs_new_earthquake_v2.png", as(png) name("Graph") replace
