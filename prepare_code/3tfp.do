clear
cd "C:\Users\chenw\Desktop\wrds\wrds"

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

use CompustatData.dta, clear
merge m:1 year using `nipa'
drop _merge

merge m:1 year using `gdp'
drop _merge

merge m:1 year using `awi'
drop _merge
duplicates drop permno year, force
drop if missing(year)
drop if missing(gvkey)

drop if sicc >= 6000 & sicc <= 6999
drop if sicc >= 4900 & sicc <= 4999
drop if missing(sale) | sale < 0
drop if missing(at) | at < 0
drop if missing(emp) | emp < 0
drop if missing(ppegt) | ppegt < 0
drop if missing(dp) | dp < 0
drop if missing(dpact) | dpact < 0
drop if missing(capx) | capx < 0


gen l = log(emp)
gen k = log(ppegt/price_k)
gen i = log(capx/price_k)
gen y = log((oibdp + emp*awi*1000/1e6)/gdpi)

xtset permno year
*gen k_lag = L.k

*industry specific time dummies 
gen exit = missing(F.y)
gen indus = int(sic/100)

opreg y, exit(exit) state(k) proxy(i) free(l) cvars(indus year) vce(bootstrap, seed(10)rep(100))
estimates store OP_opreg
gen tfp = y-_b[l]*l -_b[k]*k

drop gvkey gdpi awi sic l k i y exit indus _est_OP_opreg
save "Comp_data.dta",replace

