clear all

cd "C:\Users\chenw\Desktop\wrds\wrds"

use "patent.dta", clear

merge m:1 gyear using AcitesbyY
drop _merge
merge m:1   permno year using "firmiqr.dta"
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
**equation 6 signal-to-noise is constant across firms and time
gen delta=1-exp(-.0146289) 
gen a=-sqrt(delta)*R/v
gen m_graw3m0F=delta*R + sqrt(delta)*v*normalden(a)/(1-normal(a))
*in equation 3, the expected patent value * market capitalization M
gen mw_graw3m0F= m_graw3m0F*gmkcap/1000 
drop R v a delta
 
 

* Assume x and e are Cauchy
gen v=Lhfirmiqr*(3)
gen R=exp(log(1+gret)+log(1+gretp1)+log(1+gretp2))-1
gen delta=1-exp(-.0146289) 
*page 15 formula in appendix
gen m_graw3m0FC= ((R^2*delta^2+(-2*v^2-2*R^2)*delta+v^2+R^2)*v*log((v^2+R^2))-0.2e1*(R^2*delta^2+(-2*v^2-2*R^2)*delta+v^2+R^2)*v*log(-(v*delta/(delta-1)))+R*(((2*R^2+4*v^2)*delta^2+(-4*R^2-4*v^2)*delta+2*v^2+2*R^2)*atan((R/v))+((4*v^2+R^2)*delta^2+(-4*v^2-2*R^2)*delta+v^2+R^2)*_pi))*delta/(0.2e1*R*delta*v*((delta-1)^2)*log((v^2+R^2))-0.4e1*R*delta*v*((delta-1)^2)*log(-(v*delta/(delta-1)))+0.2e1*delta*(R^2*delta^2+(2*v^2-2*R^2)*delta+R^2-v^2)*atan((R/v))+((4*v^2+R^2)*delta^2+(-4*v^2-2*R^2)*delta+v^2+R^2)*_pi)
gen mw_graw3m0FC=m_graw3m0FC*gmkcap/1000 
drop R v  delta 

* Assume x is exponential with parameter 1/gx
gen delta=1-exp(-.0146289) 
gen v= vol*sqrt(3)
gen gx=sqrt(delta)*v
gen ge=v
gen R=exp(log(1+gret)+log(1+gretp1)+log(1+gretp2))-1
gen Rn=(-R * gx + ge^2)/ge/gx
gen yy=sqrt(0.2e1)*Rn/0.2e1
gen erfcyy=2*normal(-yy*sqrt(2))
*page 14 equation
gen ExR=-ge*exp(-Rn ^ 2 / 0.2e1) *  sqrt(0.2e1) * _pi ^ (-0.1e1 / 0.2e1) / (-erfcyy) -  ge*Rn
gen mw_graw3m0F2=ExR*gmkcap/1000 
drop  v yy delta gx R  ge erfcyy

* equation3 multiple patents Nj are issued to the same firm on the same day as patent j
gen Npats=1
replace Npats=. if missing(mw_graw3m0F)
egen CountNpats=count(Npats), by(permno issdate)

*equation 9
gen Acw=(1+ncites/avgncites)
*normal/Cauchy/exponential
gen Af2=mw_graw3m0F2/CountNpats
gen Af=mw_graw3m0F/CountNpats
gen AfC=mw_graw3m0FC/CountNpats
*now only need to times  (1 − π¯ )^−1
  
gen AfNpats=1 
 
collapse (sum) Acw Af Af2 AfC  AfNpats , by(permno year)
 

save "firm_Af.dta",replace

 
 


 
  
 
