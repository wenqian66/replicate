clear all
cd "/Users/wenqian/Desktop/ra/July18/data"


import delimited "newproduct_crsp_ccm.csv",clear
keep keydevid announcedate gvkey permno
duplicates drop

gen date2 = date(announcedate, "YMD")
format date2 %td
drop announcedate
rename date2 announcedate

tostring keydevid, replace
replace keydevid = trim(itrim(keydevid))

tempfile newproduct_date
save `newproduct_date'

import delimited "newproduct_GPT_results_manual_cleaned.csv", varnames(1) bindquote(strict) clear
replace keydevid = trim(itrim(keydevid))
merge 1:m keydevid using `newproduct_date'
drop if _merge == 1   
drop _merge 


save newproduct_base.dta,replace
