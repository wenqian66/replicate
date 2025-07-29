*
* permno year at invt ppegt emp sicc sale cogs xrd firmvol
clear
cd "/Users/wenqian/Desktop/ra/July18"

import delimited "price_k.csv", clear
tempfile nipa
save `nipa'

import delimited "gdp.csv",clear
tempfile gdp
save `gdp'

import delimited "awi.csv",clear
destring awi, replace
tempfile awi
save `awi'

import delimited "comp_funda.csv", clear
keep gvkey datadate
duplicates drop

*linktable.dta need to be preprocessed
joinby gvkey using "linktable.dta"
gen start = date(linkdt,"MDY")
gen end = date(linkenddt,"MDY")
gen comp_date = date(datadate,"YMD")
keep if (start <= comp_date & comp_date <= end) | (missing(start) & comp_date <= end)
drop linkdt linkenddt start end comp_date 

sort gvkey datadate 
tempfile cc_link
save `cc_link'

*crsp permno & comp gvkey link
import delimited "comp_funda.csv", clear
keep if datafmt == "STD"
keep if consol == "C" 
keep if indfmt == "INDL" 
merge 1:m gvkey datadate using `cc_link'
rename lpermno permno
rename fyear year
drop if missing(permno)
drop _merge
tostring sich, replace


*actually hsiccd in crsp
// import delimited "crsp_dsf.csv",clear
// keep permno date hsiccd
// duplicates drop
// 
// gen date2 = date(date,"YMD")
// format date2 %td
// gen year = year(date2)
// keep permno year hsiccd
// duplicates drop
// rename hsiccd sic
// bysort permno year (sic): keep if _n == 1
// save sic.dta, replace


merge m:1 year permno using sic.dta
gen sic2 = sich
replace sic2 = sic if missing(sic2)
drop _merge sic sich consol indfmt datafmt
rename sic2 sicc


merge m:1 year using `nipa'
drop _merge

merge m:1 year using `gdp'
drop _merge

merge m:1 year using `awi'
drop _merge
duplicates drop permno year, force
drop if missing(year)
drop if missing(gvkey)
drop if missing(sicc)
sort permno year

save "CompustatData.dta", replace
