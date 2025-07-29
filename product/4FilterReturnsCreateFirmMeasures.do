clear all

cd "/Users/wenqian/Desktop/ra/July18"

use "product.dta", clear

// merge m:1 gyear using AcitesbyY
// drop _merge
merge m:1 permno year using "firmiqr.dta"
drop if _merge==2
drop _merge

 
* gmkcap is in thousands

replace gret=0 if missing(gret)
replace gretp1=0 if missing(gretp1)
replace gretp2=0 if missing(gretp2)


*equation 4
* assume x is truncated normal with mean 0
**three-day idiosyncratic return 
gen R=exp(log(1+gret)+log(1+gretp1)+log(1+gretp2))-1 
gen v= vol*sqrt(3)
**equation 6 signal-to-noise is constant across firms and time -.1646180?
gen delta=1-exp(-.1646180) 
gen a=-sqrt(delta)*R/v
gen m_graw3m0F=delta*R + sqrt(delta)*v*normalden(a)/(1-normal(a))
*in equation 3, the expected patent value * market capitalization M
gen mw_graw3m0F= m_graw3m0F*gmkcap/1000 
drop R v a delta
 

* equation3 multiple patents Nj are issued to the same firm on the same day as patent j
gen Npats=1
replace Npats=. if missing(mw_graw3m0F)
egen CountNpats=count(Npats), by(permno announcedate)

*equation 9
// gen Acw=(1+ncites/avgncites)
*normal/Cauchy/exponential
gen Af=mw_graw3m0F/CountNpats
  
gen AfNpats=1 
 
collapse (sum) Af  AfNpats , by(permno year)
 

save "firm_Af.dta",replace

 
 


 
  
 
