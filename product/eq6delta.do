clear all
cd "/Users/wenqian/Desktop/ra/July18"


*if issuedate dummy==1 (permno-issuedate level)
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

merge m:1 permno date_crsp using `issd'
save theta.dta,replace

use theta.dta
gen gyear = year(date_crsp)
keep if gyear >= 2001 & gyear <= 2021
*restrict the sample to firms that have been granted at least one patent.
egen dpatent = max(issdummy), by(permno)
keep if dpatent == 1
drop dpatent

drop if _merge == 2
drop _merge
replace issdummy = 0 if missing(issdummy)

gen dow = dow(date_crsp)
gen long fy=permno*10000+gyear
// egen fy = group(permno gyear)

gen logR2 = 2*log(abs(R))
*winsorizeJ logR2, cuts(1 99) by(gyear)
eststo R1: reghdfe logR2 issdummy i.dow,  absorb(fy) cluster(permno)


