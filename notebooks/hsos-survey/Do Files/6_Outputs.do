********************************************************************
* REACH Humanitarian Situation Overview of Syria
* Do-file: Outputs
* Details: Line graph of selected indicators.
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
local varg RES_humani_access IDP_humani_access RES_humani_prov_cash RES_humani_prov_voucher IDP_humani_prov_cash IDP_humani_prov_voucher electricity_main IDP_priority1_2 IDP_priority1_9 RES_priority1_2 RES_priority1_9 IDP_coping_sellittem RES_coping_earlym IDP_coping_earlym


foreach i of local varg {
	egen `i'p=total(`i'), by (id treated_3)
	gen `i'c=`i'p/totalc*100
}


**Produced dataset for graphs

collapse RES_humani_accessc IDP_humani_accessc RES_humani_prov_cashc RES_humani_prov_voucherc IDP_humani_prov_cashc IDP_humani_prov_voucherc electricity_mainc IDP_priority1_2c IDP_priority1_9c RES_priority1_2c RES_priority1_9c IDP_coping_sellittemc RES_coping_earlymc IDP_coping_earlymc, by (id treated_3)

**Graph of dummy/percentage of communities


local varline electricity_mainc IDP_coping_sellittemc RES_coping_earlymc IDP_coping_earlymc

local title `""Electricity main source: community network" "IDP coping strategies:  Sell household items or assets" "RES coping strategies:Early marriage" "IDP coping strategies:Early marriage"'

local n: word count `varline'

forvalues i=1/`n' {
	local a: word `i' of `varline'
	local b: word `i' of `title'

separate `a', by(treated_3)

twoway (line `a'0 `a'1 `a'2 id if id<=3) (line `a'0 `a'1 `a'2 id if id>=4, lcolor (ebblue orange dkgreen)), legend(order(1 "Light" 2 "Moderate" 3 "Strong/Very Strong")) xtitle(Date) ytitle(% of communities) title(`b', size(small)) graphregion(color(white)) xlabel( ,valuelabel) ylabel(0 (10) 100)

graph export "${line}\1_Fig `a'.png", as(png) name("Graph") replace

}

  

*Graph 1
*HA aid received

separate RES_humani_accessc, by(treated_3)
separate IDP_humani_accessc, by(treated_3)

twoway (line RES_humani_accessc0 RES_humani_accessc1 RES_humani_accessc2 id if id<=3) (line RES_humani_accessc0 RES_humani_accessc1 RES_humani_accessc2 id if id>=4, lcolor (ebblue orange dkgreen))(line IDP_humani_accessc0 IDP_humani_accessc1 IDP_humani_accessc2 id if id<=3, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)) (line IDP_humani_accessc0 IDP_humani_accessc1 IDP_humani_accessc2 id if id>=4, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)), legend(order(1 "RES: Light" 2 "RES: Moderate" 3 "RES: Strong/Very Strong" 7 "IDP: Light" 8 "IDP: Moderate" 9 "IDP: Strong/Very Strong")) legend(col (3) pos(6)) xtitle(Date) ytitle(% of communities) graphregion(color(white)) xlabel( ,valuelabel) ylabel(0 (10) 100) title(Access to humanitarian aid, size(small))

graph export "${line}\1_Fig HA access.png", as(png) name("Graph") replace


*Graph 2 
*Cash
separate RES_humani_prov_cashc, by(treated_3)
separate IDP_humani_prov_cashc, by(treated_3)

twoway (line RES_humani_prov_cashc0 RES_humani_prov_cashc1 RES_humani_prov_cashc2 id if id<=3) (line RES_humani_prov_cashc0 RES_humani_prov_cashc1 RES_humani_prov_cashc2 id if id>=4, lcolor (ebblue orange dkgreen))(line IDP_humani_prov_cashc0 IDP_humani_prov_cashc1 IDP_humani_prov_cashc2 id if id<=3, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)) (line IDP_humani_prov_cashc0 IDP_humani_prov_cashc1 IDP_humani_prov_cashc2 id if id>=4, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)), legend(order(1 "RES: Light" 2 "RES: Moderate" 3 "RES: Strong/Very Strong" 7 "IDP: Light" 8 "IDP: Moderate" 9 "IDP: Strong/Very Strong")) legend(col (3) pos(6)) xtitle(Date) ytitle(% of communities) graphregion(color(white)) xlabel( ,valuelabel) ylabel(0 (10) 100) title(Access to humanitarian aid:cash, size(small))

graph export "${line}\1_Fig HA access cash .png", as(png) name("Graph") replace

*Food vouchers
separate RES_humani_prov_voucherc, by(treated_3)
separate IDP_humani_prov_voucherc, by(treated_3)

twoway (line RES_humani_prov_voucherc0 RES_humani_prov_voucherc1 RES_humani_prov_voucherc2 id if id<=3) (line RES_humani_prov_voucherc0 RES_humani_prov_voucherc1 RES_humani_prov_voucherc2 id if id>=4, lcolor (ebblue orange dkgreen))(line IDP_humani_prov_voucherc0 IDP_humani_prov_voucherc1 IDP_humani_prov_voucherc2 id if id<=3, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)) (line IDP_humani_prov_voucherc0 IDP_humani_prov_voucherc1 IDP_humani_prov_voucherc2 id if id>=4, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)), legend(order(1 "RES: Light" 2 "RES: Moderate" 3 "RES: Strong/Very Strong" 7 "IDP: Light" 8 "IDP: Moderate" 9 "IDP: Strong/Very Strong")) legend(col (3) pos(6)) xtitle(Date) ytitle(% of communities) graphregion(color(white)) xlabel( ,valuelabel) ylabel(0 (10) 100) title(Access to humanitarian aid:food vouchers, size(small))

graph export "${line}\1_Fig HA access voucher .png", as(png) name("Graph") replace

*Graph 3


separate RES_priority1_2c, by(treated_3)
separate IDP_priority1_2c, by(treated_3)

twoway (line RES_priority1_2c0 RES_priority1_2c1 RES_priority1_2c2 id if id<=3) (line RES_priority1_2c0 RES_priority1_2c1 RES_priority1_2c2 id if id>=4, lcolor (ebblue orange dkgreen))(line IDP_priority1_2c0 IDP_priority1_2c1 IDP_priority1_2c2 id if id<=3, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)) (line IDP_priority1_2c0 IDP_priority1_2c1 IDP_priority1_2c2 id if id>=4, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)), legend(order(1 "RES: Light" 2 "RES: Moderate" 3 "RES: Strong/Very Strong" 7 "IDP: Light" 8 "IDP: Moderate" 9 "IDP: Strong/Very Strong")) legend(col (3) pos(6)) xtitle(Date) ytitle(% of communities) xlabel( ,valuelabel) ylabel(0 (10) 100) title(Top priority:food, size(small))

graph export "${line}\1_Fig Top priority food .png", as(png) name("Graph") replace


*Graph 4

separate RES_priority1_9c, by(treated_3)
separate IDP_priority1_9c, by(treated_3)

twoway (line RES_priority1_9c0 RES_priority1_9c1 RES_priority1_9c2 id if id<=3) (line RES_priority1_9c0 RES_priority1_9c1 RES_priority1_9c2 id if id>=4, lcolor (ebblue orange dkgreen))(line IDP_priority1_9c0 IDP_priority1_9c1 IDP_priority1_9c2 id if id<=3, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)) (line IDP_priority1_9c0 IDP_priority1_9c1 IDP_priority1_9c2 id if id>=4, lcolor (ebblue orange dkgreen) lpattern(dash dash dash)), legend(order(1 "RES: Light" 2 "RES: Moderate" 3 "RES: Strong/Very Strong" 7 "IDP: Light" 8 "IDP: Moderate" 9 "IDP: Strong/Very Strong")) legend(col (3) pos(6)) xtitle(Date) ytitle(% of communities) xlabel( ,valuelabel) ylabel(0 (10) 100) title(Top priority:shelter, size(small))

graph export "${line}\1_Fig Top priority shelter .png", as(png) name("Graph") replace
