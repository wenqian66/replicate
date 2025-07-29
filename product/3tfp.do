clear
cd "/Users/wenqian/Desktop/ra/July18"

import delimited "price_k.csv", clear
rename year cap_year 
rename price_k adprice_k
tempfile nipa
save `nipa'

use CompustatData,clear

destring sicc, replace
drop if sicc >= 6000 & sicc <= 6999
drop if sicc >= 4900 & sicc <= 4999

drop if missing(sale) | sale <= 0
drop if missing(at) | at <= 0
drop if missing(emp) | emp <= 0
drop if missing(ppegt) | ppegt <= 0
drop if missing(ppent) | ppent <= 0
drop if missing(capx) | capx <= 0
drop if missing(dp) | dp <= 0

drop if year > 2021
drop if year < 2000
*Since investment is made at various times in the past, we need to calculate the average age of capital at every year for each company and apply the appropriate deflator (assuming that investment is made all at once in year [current year - age]). 
* alculate the average age of capital at every year for each company
gen cap_age = (ppegt - ppent) / dp

*Age is further smoothed by taking a 3-year moving average.
gen cap_age_smooth = .
bysort permno (year): replace cap_age_smooth = (cap_age[_n-1] + cap_age + cap_age[_n+1]) / 3 if _n > 1 & _n < _N
replace cap_age_smooth = cap_age if missing(cap_age_smooth)
gen int cap_year = year - round(cap_age_smooth)
drop cap_age cap_age_smooth 

merge m:1 cap_year using `nipa'
drop if _merge != 3
gen k = log(ppegt/adprice_k)
// gen i = log(capx/adprice_k)
drop _merge

***********
gen l = log(emp)
// gen k = log(ppegt/price_k)
gen i = log(capx/price_k)
gen y = log((oibdp + emp*awi*1000/1e6)/gdpi)
drop if missing(i)
drop if missing(k)
drop if missing(y)

xtset permno year

*industry specific time dummies 
*2021 as the last day of data
bysort permno (year): gen last_obs = (_n == _N)
gen has_2021 = (year == 2021)
bysort permno (has_2021): replace has_2021 = has_2021[_n-1] if missing(has_2021)
gen has_gap = 0
bysort permno (year): replace has_gap = 1 if year != year[_n-1] + 1 & _n != 1
bysort permno (year): replace has_gap = has_gap[_n-1] if missing(has_gap)
gen exit = (last_obs == 1 & has_2021 == 0 & has_gap == 0)
replace exit = 0 if year == 2021

drop if missing(exit)
drop if missing(sicc)
bysort permno (year): drop if missing(L.k)|missing(l.i)
// bysort permno:gen nobs = _N
// drop if nobs<2
// drop nobs

gen indus = int(sicc/100)

xi: opreg y, exit(exit) state(k) proxy(i) free(l) cvars(i.indus i.year) vce(bootstrap, seed(10)rep(50))
estimates store OP_opreg
gen tfp = y-_b[l]*l -_b[k]*k

// predict resid, resid
// gen tfp2 = resid

keep permno year tfp
save "tfp.dta",replace

// // *******
// *create the CompustatData!!!!!
use vol_table.dta
keep year vol permno 
duplicates drop
tempfile vol_table
save `vol_table'

//
*Dec gmkcap
import delimited "crsp_msf.csv", clear
gen date_m = date(date, "YMD")
format date_m %td
keep if month(date_m) == 12
gen mkcap = abs(prc) * shrout
gen year = year(date_m)
keep permno year mkcap
duplicates drop
tempfile mkcap
save `mkcap'


use CompustatData,clear
merge 1:1 permno year using `vol_table'
drop _merge
sort permno year
rename vol firmvol
duplicates drop

merge 1:1 permno year using `mkcap'
drop _merge
sort permno year

merge 1:1 permno year using tfp.dta
keep if _merge != 2
drop _merge
keep if !missing(gvkey)
drop gvkey
save "Comp_data.dta",replace
