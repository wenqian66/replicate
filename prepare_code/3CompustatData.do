*
// permno year at invt ppegt emp sicc sale cogs xrd firmvol
clear
cd "C:\Users\chenw\Desktop\wrds\wrds"


*crsp permno & comp gvkey link
import delimited "comp_funda.csv", clear
keep gvkey datadate
duplicates drop

merge m:m gvkey using "linktable.dta"
keep if _merge == 3
gen start = date(linkdt,"YMD")
gen end = date(linkenddt,"YMD")
gen comp_date = date(datadate,"YMD")
replace end = date("2025-12-31", "YMD") if missing(end)
keep if (start <= comp_date & comp_date <= end) | (missing(start) & comp_date <= end)
drop linkdt linkenddt linktype start end comp_date _merge

sort gvkey datadate 
tempfile cc_link
save `cc_link'

*CRSP's hsiccd not work, use the paper's
// import delimited "crsp_sic.csv",clear
// tempfile crsp_sic
// save `crsp_sic'

import delimited "comp_funda.csv", clear
keep if datafmt == "STD"
keep if consol == "C" 
keep if indfmt == "INDL" 
keep if popsrc == "D"
merge 1:m gvkey datadate using `cc_link'
rename lpermno permno
rename fyear year
drop if missing(permno)
drop _merge

merge m:1 year permno using sic.dta
drop if _merge == 2
drop _merge sich consol indfmt popsrc datafmt


// merge m:1 year permno using `crsp_sic'
// rename hsiccd sicc
//
// sort permno year
// gen sicc_fill = sicc
// bysort permno (year): replace sicc_fill = sicc_fill[_n-1] if missing(sicc_fill)
//
// gsort permno -year
// bysort permno (year): replace sicc_fill = sicc_fill[_n-1] if missing(sicc_fill)
//
// replace sicc = sicc_fill
// drop sicc_fill

save "CompustatData.dta", replace

