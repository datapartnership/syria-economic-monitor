********************************************************************
* Multi-Sectoral Needs Assesment
* Do-file: Maps
* Autor: Ivonne Lara (ivilaco@hotmail.com)(ilaracortes@worldbank.org)
********************************************************************

	clear all

	cd "C:\Users\wb607344\OneDrive - WBG\Documents\Tasks\Syria\MSNA"
	global msna "C:\Users\wb607344\OneDrive - WBG\Documents\Tasks\Syria\MSNA"
	global data "${msna}\Data"
	global output "${msna}\Output"

	sysdir set PLUS "${msna}\Codes\ado"

	* Install packages
	*ssc install spmap
	
******************* Data processing Population

******************* Data processing Humanitarian Aid

	*import delimited "${data}\Coded\aid_dis_2022.csv", clear	
	import delimited "${data}\Coded\pop_2022.csv", clear	

		* Location type
		cap replace type_location = "1" if type_location == "Camp"
		cap replace type_location = "2" if type_location == "Community"
		cap replace type_location = "3" if type_location == "Neighborhood"
		
		cap destring type_location, replace
		
		cap lab define type_loc 1 "Camp" 2 "Community" 3 "Neighborhood"
		cap lab values type_location type_loc
		
		* HH population type
		cap replace hh_pop_type = "1" if hh_pop_type == "Host population"
		cap replace hh_pop_type = "2" if hh_pop_type == "Internally displaced person (IDP)"
		cap replace hh_pop_type = "3" if hh_pop_type == "Returnee (returned in 2022)"
		
		cap destring hh_pop_type, replace
		
		cap lab define hh_pop 1 "Host population" 2 "Internally displaced person (IDP)" 3 "Returnee (returned in 2022)"
		cap lab values hh_pop_type hh_pop

		* Sub District
		rename subdis_code ADM3_PCODE
		
		/* Percentage of hh with access to aid
		gen catIDPs_new=. 
		replace catIDPs_new=1 if per_aid_hh_rec==0
		replace catIDPs_new=2 if per_aid_hh_rec>0 & per_aid_hh_rec<25
		replace catIDPs_new=3 if per_aid_hh_rec>=25 & per_aid_hh_rec<50
		replace catIDPs_new=4 if per_aid_hh_rec>=50 & per_aid_hh_rec<75
		replace catIDPs_new=5 if per_aid_hh_rec>=75

		label define cat 1 "0%" 2 "1% - 24%" 3 "25% - 49%" 4 "50% - 74%" 5 "75% - 100%"
		label values catIDPs_new cat
		*/
		
		* Percentage of hh with access to aid
		gen catIDPs_new=. 
		replace catIDPs_new=1 if pop==0
		replace catIDPs_new=2 if pop>0 & pop<=325
		replace catIDPs_new=3 if pop>325 & pop<=650
		replace catIDPs_new=4 if pop>650 & pop<=975
		replace catIDPs_new=5 if pop>975 & pop<=1300
		replace catIDPs_new=6 if pop>1300 & pop<=1625
		replace catIDPs_new=7 if pop>1625 & pop<=1950
		replace catIDPs_new=8 if pop>1950 & pop<=2275
		replace catIDPs_new=9 if pop>2275
		
		label define cat 1 "0" 2 "1 - 325" 3 "326 - 650" 4 "651 - 975" 5 "976 - 1300" 6 "1301 - 1625" 7 "1626 - 1950" 8 "1951 - 2275" 9 "2276 - 2600"
		label values catIDPs_new cat
		*/
		

******************* Map 

	*
	forvalues i=1/3 {
		
		preserve 
		
		keep if hh_pop_type == `i'
		cap merge 1:m ADM3_PCODE using "${data}\Raw\syria3.dta", keepusing(_ID)

		spmap catIDPs_new using "${data}\Raw\syria3_shp.dta", ///
		id(_ID) clm(u) legend(pos(4)) fcolor(Reds) ndo(gs10) ///
		legend(title("Total population", size(2.3) justification(left)))
		
		graph export "${output}\pop_`i'.png", replace	
		
		restore
	}



	*spshape2dta "${data}\Raw\syr_admbnda_adm3_uncs_unocha_20201217-polygon.shp", replace saving(syria3)
	
	* Camp
		preserve
		
		keep if type_location == 1 & hh_pop_type == 2
		cap merge 1:m ADM3_PCODE using "${data}\Raw\syria3.dta", keepusing(_ID)

		spmap catIDPs_new using "${data}\Raw\syria3_shp.dta", ///
		id(_ID) clm(u) legend(pos(4)) fcolor(Greens) ndo(gs10) ///
		legend(title("Percentage of households with" "access to humanitarian aid", size(2.3) justification(left)))

		cap graph export "${output}\map_per_hh_aid_1_2.png", replace

		restore
		
	* Community
	forvalues i = 1/3 {

		preserve
		
		keep if type_location == 2 & hh_pop_type == `i'	
		cap merge 1:m ADM3_PCODE using "${data}\Raw\syria3.dta", keepusing(_ID)

		spmap catIDPs_new using "${data}\Raw\syria3_shp.dta", ///
		id(_ID) clm(u) legend(pos(4)) fcolor(Blues) ndo(gs10) ///
		legend(title("Percentage of households with" "access to humanitarian aid", size(2.3) justification(left)))

		cap graph export "${output}\map_per_hh_aid_2_`i'.png", replace

		restore

	}
		
	* Neighborhood
	forvalues i = 1/3 {

		preserve
		
		keep if type_location == 3 & hh_pop_type == `i'
		cap merge 1:m ADM3_PCODE using "${data}\Raw\syria3.dta", keepusing(_ID)

		spmap catIDPs_new using "${data}\Raw\syria3_shp.dta", ///
		id(_ID) clm(u) legend(pos(4)) fcolor(Oranges) ndo(gs10) ///
		legend(title("Percentage of households with" "access to humanitarian aid", size(2.3) justification(left)))

		cap graph export "${output}\map_per_hh_aid_3_`i'.png", replace

		restore

	}
