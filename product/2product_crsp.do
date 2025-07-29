clear all
cd "/Users/wenqian/Desktop/ra/July18"

*idio_ret/mktcap
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
gen mktcap = abs(prc) * shrout
rename date2 date_crsp
keep permno date_crsp idio_ret mktcap

tempfile crsp
save `crsp'

*vol
use `crsp',clear
keep permno date_crsp idio_ret
gen year = year(date_crsp)
gen idio_sq = idio_ret^2
collapse (mean) sigma2 = idio_sq, by(permno year)
gen vol = sqrt(sigma2)
drop sigma2
save vol_table.dta,replace

*gret, gretp1, gretp2 , issdate + 2 later trading day -1trading day for mktcap
**construct trading date table? avoid vacations?
**last trading date
use `crsp',clear
keep permno date_crsp
duplicates drop
gen tag = 0
tempfile t_day
save `t_day'

use "newproduct_base.dta", clear
gen date_crsp = announcedate
format date_crsp %td
keep permno date_crsp
duplicates drop
gen tag = 1

append using `t_day'
bysort permno date_crsp (tag): keep if _n == 1  // keep crsp row if duplicated
bysort permno (date_crsp): gen rank = _n
drop tag
tempfile link
save `link' 

**the trading date tables 
use `link', clear
rename date_crsp linked_date
gen rank_mkt = rank + 1
drop rank
rename rank_mkt rank
keep permno rank linked_date
duplicates drop
tempfile r_mkt
save `r_mkt'

use `link', clear
rename date_crsp linked_date
gen rank_1 = rank - 1
drop rank
rename rank_1 rank
keep permno rank linked_date
duplicates drop
tempfile r_1
save `r_1'

use `link', clear
rename date_crsp linked_date
gen rank_2 = rank - 2
drop rank
rename rank_2 rank
keep permno rank linked_date
duplicates drop
tempfile r_2
save `r_2'

**merge back to find date_mkt/date_1/date_2
use "newproduct_base.dta", clear
gen date_crsp = announcedate
format date_crsp %td

merge m:1 permno date_crsp using `crsp', keep(master match) nogen
rename idio_ret gret

merge m:1 permno date_crsp using `link', keep(master match) nogen
drop mktcap date_crsp

merge m:1 permno rank using `r_mkt', keep(master match) nogen
rename linked_date date_mkt

merge m:1 permno rank using `r_1', keep(master match) nogen
rename linked_date date_1

merge m:1 permno rank using `r_2', keep(master match) nogen
rename linked_date date_2

format date_mkt date_1 date_2 %td


**merge back to find gmkcap/gretp1/gretp2
rename date_mkt date_crsp
merge m:1 permno date_crsp using `crsp', keep(master match) nogen
rename mktcap gmkcap
drop date_crsp idio_ret rank

rename date_1 date_crsp
merge m:1 permno date_crsp using `crsp', keep(master match) nogen
rename idio_ret gretp1
drop date_crsp mktcap  

rename date_2 date_crsp
merge m:1 permno date_crsp using `crsp', keep(master match) nogen
rename idio_ret gretp2
drop date_crsp mktcap 

*vol
gen year = year(announcedate)
merge m:1 permno year using vol_table.dta, keep(master match) nogen

save product.dta,replace
