clear all
cd "/Users/wenqian/Desktop/ra/July18"


*if issuedate dummy==1 (permno-issuedate level) obs:315626
use newproduct_base.dta,clear
keep permno announcedate
duplicates drop
gen issdummy = 1
rename announcedate date_crsp
tempfile issd
save `issd'

*idio_ret
import delimited using "crsp_dsi.csv", clear
gen date2 = date(date, "YMD")
format date2 %td
tempfile dsi
save `dsi'

import delimited using "crsp_dsf.csv", clear
gen date2 = date(date, "YMD")
format date2 %td

merge m:1 date2 using `dsi', keep(match) nogen
gen year = year(date2)

gen ret_num = real(ret)
drop ret
rename ret_num ret
gen idio_ret = ret - vwretd
rename date2 date_crsp
keep permno date_crsp idio_ret
duplicates drop
sort permno date_crsp
*one day gap
// tsset permno date_crsp
// gen idio_ret1 = F.idio_ret 
// gen idio_ret2 = F2.idio_ret 
gen idio_ret1 = idio_ret[_n+1] if permno == permno[_n+1]
gen idio_ret2 = idio_ret[_n+2] if permno == permno[_n+2]
gen R=exp(log(1+idio_ret)+log(1+idio_ret1)+log(1+idio_ret2))-1 

*too much _merge == 2
merge m:1 permno date_crsp using `issd'
save theta.dta,replace

use theta.dta,clear
*for those not announced in trading day, match to the nearest later? permno-date_crsp? or just set the nearest next day issdummy==1?
gen flag_merge2 = (_merge == 2)
gsort permno date_crsp

gen shift = 0
replace shift = 1 if flag_merge2 == 1 & permno == permno[_n+1]
replace issdummy = 1 if shift[_n-1] == 1 & permno == permno[_n-1] 
drop if _merge == 2
drop flag_merge2 shift _merge
*****************************************************************

gen gyear = year(date_crsp)
keep if gyear >= 2001 & gyear <= 2021
*restrict the sample to firms that have been granted at least one patent.
egen dpatent = max(issdummy), by(permno)
keep if dpatent == 1
drop dpatent

replace issdummy = 0 if missing(issdummy)
*paper use 1926-2010, year<=1952 exits dow==6, here only 5 vars ;
*gamma = .1798662; delta = .164618022      ?
gen dow = dow(date_crsp)
gen long fy=permno*10000+gyear
// egen fy = group(permno gyear)

gen logR2 = 2*log(abs(R))
*winsorizeJ logR2, cuts(1 99) by(gyear)
eststo R1: reghdfe logR2 issdummy i.dow,  absorb(fy) cluster(permno)


