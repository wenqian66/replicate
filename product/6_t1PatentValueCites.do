clear all

cd "/Users/wenqian/Desktop/ra/July18"

use "product.dta", clear
 

merge m:1  year using cpi
drop if _merge==2
drop _merge

merge m:1   permno year using "firmiqr.dta"
drop if _merge==2
drop _merge
//
// merge m:1 gyear using AcitesbyY
// drop _merge

 
 
* gmkcap is in thousands

replace gret=0 if missing(gret)
replace gretp1=0 if missing(gretp1)
replace gretp2=0 if missing(gretp2)
 
 
* assume x is truncated normal with mean 0
gen R=exp(log(1+gret)+log(1+gretp1)+log(1+gretp2))-1
gen v= vol*sqrt(3)
gen delta=1-exp(-.1646180) 
 gen a=-sqrt(delta)*R/v
gen m_graw3m0F=delta*R + sqrt(delta)*v*normalden(a)/(1-normal(a))
gen mw_graw3m0F= m_graw3m0F*gmkcap/10/cpi
drop R v a delta

 
gen Npats=1

egen CountNpats=count(Npats), by(permno announcedate)

*firm-year unique id
gen long fy=permno*10000+gyear
 
 *class*year unique id
// gen long gyearC=classN+gyear*1000

gen Af=mw_graw3m0F/CountNpats
   
// gen logN =log(1+ncites)
gen logP=log(CountNpats)

gen logAf=log(Af)

gen logvol=log(vol)

gen logM=log(gmkcap)


// gen  citeadj=ncites/avgncites


gen Ret=100*(exp(log(1+gret)+log(1+gretp1)+log(1+gretp2))-1) 

replace  m_graw3m0F= m_graw3m0F*100

* adjust values for acceptance probability (note, there is a typo in the paper text and pi should be 0.55 instead)
// replace Af=Af/(1-0.55)



* Descriptive statistics for the patent-level measure (Table 1 in the paper and A.6 in the Online Appendix)
tabstat  Ret m_graw3m0F Af , stat(mean sd p1 p5 p10 p25 p50 p75 p90 p95 p99)

* winsorize all variables using annual breakpoints
winsorizeJ logAf logN logvol  logM logP, cuts(1 99) by(gyear)

* Regress estimated market values on citations (replicates Table 2 in paper)
eststo R1: areg logAfW logNW,     absorb(gyearC) cluster(gyear)
eststo R2: areg logAfW logNW    logMW   ,     absorb(gyearC) cluster(gyear)
eststo R3: areg logAfW logNW logvolW logMW    ,     absorb(gyearC) cluster(gyear)
eststo R4: reghdfe logAfW logNW logvolW  logMW  ,     absorb(permno gyearC) cluster(gyear)
eststo R5: reghdfe logAfW logNW logvolW  logMW  ,     absorb(fy gyearC) cluster(gyear) 
eststo R6: reghdfe logAfW logNW logvolW  logMW  logPW,     absorb(fy gyearC) cluster(gyear)
eststo R7: reghdfe logAfW logNW logvolW  logMW  logPW,     absorb(permno gyearC) cluster(gyear)

esttab R1 R2 R3 R4 R5, r2 keep (logNW)  fragment tex b(3) t(2) nostar  replace

* Regress estimated market values on citations for alternative measures (replicates Table A.7 in the Online Appendix)

* Citations on filtered values (assuming exponential)  
eststo R1: areg logAfEW logNW,     absorb(gyearC) cluster(gyear)
eststo R2: areg logAfEW logNW    logMW   ,     absorb(gyearC) cluster(gyear)
eststo R3: areg logAfEW logNW logvolW logMW    ,     absorb(gyearC) cluster(gyear)
eststo R4: reghdfe logAfEW logNW logvolW  logMW  ,     absorb(permno gyearC) cluster(gyear)
eststo R5: reghdfe logAfEW logNW logvolW  logMW  ,     absorb(fy gyearC) cluster(gyear) 
eststo R6: reghdfe logAfEW logNW logvolW  logMW  logPW,     absorb(fy gyearC) cluster(gyear)
eststo R7: reghdfe logAfEW logNW logvolW  logMW  logPW,     absorb(permno gyearC) cluster(gyear)

esttab R1 R2 R3 R4 R5, r2 keep (logNW)  fragment tex b(3) t(2) nostar  replace 
 
* Citations on filtered values (assuming Cauchy)
eststo R1: areg logAfCW logNW,     absorb(gyearC) cluster(gyear)
eststo R2: areg logAfCW logNW    logMW   ,     absorb(gyearC) cluster(gyear)
eststo R3: areg logAfCW logNW logvolW logMW    ,     absorb(gyearC) cluster(gyear)
eststo R4: reghdfe logAfCW logNW logvolW  logMW  ,     absorb(permno gyearC) cluster(gyear)
eststo R5: reghdfe logAfCW logNW logvolW  logMW  ,     absorb(fy gyearC) cluster(gyear) 
eststo R6: reghdfe logAfCW logNW logvolW  logMW  logPW,     absorb(fy gyearC) cluster(gyear)
eststo R7: reghdfe logAfCW logNW logvolW  logMW  logPW,     absorb(permno gyearC) cluster(gyear)

esttab R1 R2 R3 R4 R5, r2 keep (logNW)  fragment tex b(3) t(2) nostar  replace 
 
 
