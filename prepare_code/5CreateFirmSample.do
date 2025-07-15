* This file merges the innovation measure with Compustat data and creates the needed variables to run the firm-level regressions*

clear all

cd "C:\Users\chenw\Desktop\wrds\wrds"

use patent.dta
keep year vol permno 
duplicates drop
tempfile patent
save `patent'

*cpi
import delimited "CPIAUCNS.csv", clear
*don't know why need /2.145
gen cpi = rcpi/2.145
drop rcpi
tempfile cpi
save `cpi'

*Dec gmkcap
import delimited "crsp_msf.csv", clear
gen date_m = date(date, "YMD")
format date_m %td
gen mkcap = abs(prc) * shrout
gen year = year(date_m)
keep permno year mkcap
duplicates drop
tempfile mkcap
save `mkcap'


use Comp_data, clear

sort permno year
tsset permno year
gen issdate = date(datadate, "YMD")
format issdate %td

merge 1:1 permno year using firm_Af.dta
drop if _merge == 2
drop _merge
sort permno year
duplicates drop


merge 1:1 permno year using `patent'
drop if _merge == 2
drop _merge
sort permno year
rename vol firmvol
duplicates drop

merge m:1 year using `cpi'
drop if _merge == 2
drop _merge
sort permno year

merge 1:1 permno year using `mkcap'
drop _merge
sort permno year

*Inventories - Total
replace invt=0 if missing(invt)
*Property, Plant and Equipment - Total (Gross)
replace ppegt=. if ppegt<0

*first diff
gen Dinvt=D.invt

replace invt=0 if missing(invt)

*growth rate in firm employment (COMPUSTAT: emp）
gen demp=D.emp/(L.emp)
gen sic =  real(sicc)
drop if sic >= 6000 &  sic <= 6799 
drop if sic >= 4900 &  sic <= 4949
drop sicc
rename sic sicc

*SIC3
gen indcd=floor(sicc/10)
*Cost of Goods Sold
gen profits=sale-cogs

*firm output (COMPUSTAT: sale plus change in inventories COMPUSTAT: invt, deflated by the CPI
gen logY=log((sale+Dinvt)/cpi*100)
*firm gross profits (COMPUSTAT: sale minus COMPUSTAT: cogs, deflated by the CPI
gen logP=log(profits/cpi*100)

gen logvol=log(firmvol)
gen Lvol_iret=L.logvol


replace Acw=0 if missing(Acw)
replace Af=0 if missing(Af)
 
 
* Create Innovation by Competitors  

drop if missing(indcd)
drop if missing(at) 
gen rawAf=Af
gen rawAcw=Acw 

egen mAf=mean(Af), by(indcd)
drop if mAf==0
egen iat = sum(at), by(year indcd)
egen iSALE = sum(sale), by(year indcd)


replace xrd=0 if missing(xrd)
replace xrd=. if year<1970

*Research and Development Expense
gen ARD=xrd/sale

*innovative activity of its competitors
*equation (11) 
egen xrdI = sum(xrd), by(year indcd)
gen ARDI=(xrdI-xrd)/(iSALE-sale)

*sm 
egen AfI = sum(Af), by(year indcd)
replace AfI=(AfI-Af)/(iat-at)

*cw
egen  AcwI= sum(Acw), by(year indcd)
replace AcwI=(AcwI-Acw)/(iat-at)

*Equation 10 innovation/book assets
replace Af=Af/at
replace Acw=Acw/at

*firm employment (COMPUSTAT: emp) 
gen logH=log(emp)
*firm capital stock (COMPUTAT: ppegt, deflated by the NIPA price of equipment)
gen logK=log(ppegt/price_k)
*firm TFPR, constructed using the methodology of Olley and Pakes(1996)
gen logX=tfp

gen LlogK=L.logK 
gen LlogH=L.logH 
 
 
drop if AfI<0
drop if AcwI<0
drop if year<1950
drop if year>2010

*winsorize the variables using annual breakpoints
winsorizeJ LlogK LlogH logY logP logK logH logX   , by(year) cuts(1 99)
replace LlogK=LlogKW
replace LlogH=LlogHW

 
replace logY=logYW
replace logP=logPW
replace logK=logKW
replace logH=logHW
replace logX=logXW

winsorizeJ Lvol_iret, by(year) cuts(1 99)
replace Lvol_iret=Lvol_iretW


winsorizeJ  Af AfI  Acw AcwI ARD ARDI, by(year) cuts(1 99)
replace AfI=AfIW
replace Af=AfW
replace AcwI=AcwIW
replace Acw=AcwW
replace ARD=ARDW
replace ARDI=ARDIW
  
duplicates drop
save "firm_data.dta", replace
