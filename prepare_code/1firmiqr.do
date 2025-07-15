clear all
cd  "C:\Users\chenw\Desktop\wrds\wrds"

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

*idio_ret = ret - vwretd
gen idio_ret = ret - vwretd

*hfirmiqr = one-half the interquartile range of firm-year idiosyncratic returns
*lhfirmiqr = last year hfirmiqr
bysort permno year: egen q1 = pctile(idio_ret), p(25)
bysort permno year: egen q3 = pctile(idio_ret), p(75)
gen iqr = q3 - q1
gen hfirmiqr = iqr / 2

bysort permno year (date2): keep if _n == 1
drop q1 q3 iqr 

sort permno year
by permno: gen Lhfirmiqr = hfirmiqr[_n-1] if year == year[_n-1] + 1


format hfirmiqr Lhfirmiqr %12.10f  
keep permno year hfirmiqr Lhfirmiqr
order permno year hfirmiqr Lhfirmiqr

save "firmiqr.dta", replace
