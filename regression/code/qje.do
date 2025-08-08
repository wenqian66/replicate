clear all

cd "/Users/wenqian/Desktop/ra/Aug1/data"

import delimited "KPSS_2023.csv",clear
gen Npats=1
replace Npats=. if missing(xi_nominal)
egen CountNpats=count(Npats), by(permno issue_date)

*equation 9
gen Af=xi_nominal/CountNpats
gen AfNpats=1 

gen year  = floor(issue_date / 10000)
collapse (sum) Af  AfNpats , by(permno year)
save "qje_Af.dta",replace

use Comp_data, clear
replace year = round(year)
recast long year

sort permno year
tsset permno year


merge 1:1 permno year using qje_Af.dta
drop if _merge == 2
drop _merge
sort permno year
duplicates drop

*Inventories - Total
replace invt=0 if missing(invt)
*Property, Plant and Equipment - Total (Gross)
replace ppegt=. if ppegt<0

*first diff
gen Dinvt=D.invt

replace invt=0 if missing(invt)

*growth rate in firm employment (COMPUSTAT: emp）
gen demp=D.emp/(L.emp)
destring sicc, replace
drop if sicc >= 6000 &  sicc <= 6799 
drop if sicc >= 4900 &  sicc <= 4949

*SIC3
gen indcd=floor(sicc/10)

replace Af=0 if missing(Af)
 
* Create Innovation by Competitors  
drop if missing(indcd)
drop if missing(at) 
gen rawAf=Af

egen mAf=mean(Af), by(indcd)
drop if mAf==0
egen iat = sum(at), by(year indcd)
egen iSALE = sum(sale), by(year indcd)

*innovative activity of its competitors
*equation (11) 
*sm 
egen AfI = sum(Af), by(year indcd)
replace AfI=(AfI-Af)/(iat-at)

*Equation 10 innovation/book assets
replace Af=Af/at
 
drop if AfI<0
drop if year<1997
drop if year>2022


winsorizeJ  Af AfI , by(year) cuts(1 99)
replace AfI=AfIW
replace Af=AfW

gen qje_Af = Af
gen qje_AfI = AfI
keep permno year qje_Af qje_AfI

duplicates drop
save "qje_data.dta",replace
