clear all
cd "/Users/wenqian/Desktop/ra/Aug1/data"

use "firm_data.dta", clear
merge 1:1 permno year using qje_data.dta
drop if _merge == 2
drop _merge
replace qje_Af=0 if missing(qje_Af)
replace qje_AfI=0 if missing(qje_AfI)

tsset permno year
gen F0logP=(logP)-L.logP
gen F1logP=(F1.logP)-L.logP
gen F2logP=(F2.logP)-L.logP
gen F3logP=(F3.logP)-L.logP
gen F4logP=(F4.logP)-L.logP
gen F5logP=(F5.logP)-L.logP
gen F6logP=(F6.logP)-L.logP
gen F7logP=(F7.logP)-L.logP
 

gen LlogP=L.logP

* Innovation using qje patent value
gen LSA2f_qje=L.qje_Af

* Innovation by the firm(product value)
gen LSA2f=L.Af

* This matrix holds the standardized coefficients (Innovation scaled to unit standard deviation)
matrix stoSTD = J(2,8,.) 


eststo prod_C0: qui xi: cluster2  F0logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   ,  fcluster(permno) tcluster(year)  
qui xi:  reg F0logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   
qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,1]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,1]=r(sd) * _b[LSA2f_qje]

predict F0logPp, xb
gen F0logPnC=F0logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C1: qui xi: cluster2  F1logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year)   
qui xi:  reg F1logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,2]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,2]=r(sd) * _b[LSA2f_qje]

predict F1logPp, xb
gen F1logPnC=F1logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C2: qui xi: cluster2  F2logP    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year)   
qui xi:  reg F2logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,3]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,3]=r(sd) * _b[LSA2f_qje]

predict F2logPp, xb
gen F2logPnC=F2logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C3: qui xi: cluster2  F3logP    LlogK LlogH     i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year)  
qui xi:  reg F3logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,4]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,4]=r(sd) * _b[LSA2f_qje]

predict F3logPp, xb
gen F3logPnC=F3logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C4: qui xi: cluster2  F4logP   LlogK  LlogH     i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret   LlogP ,  fcluster(permno) tcluster(year)   
qui xi:  reg F4logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,5]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,5]=r(sd) * _b[LSA2f_qje]

predict F4logPp, xb
gen F4logPnC=F4logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f


eststo prod_C5: qui xi: cluster2  F5logP    LlogK   LlogH   i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year) 
qui xi:  reg F5logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,6]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,6]=r(sd) * _b[LSA2f_qje]

predict F5logPp, xb
gen F5logPnC=F5logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C6: qui xi: cluster2  F6logP    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year)   
qui xi:  reg F6logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,7]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,7]=r(sd) * _b[LSA2f_qje]

predict F6logPp, xb
gen F6logPnC=F6logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C7: qui xi: cluster2  F7logP    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP ,  fcluster(permno) tcluster(year)  
qui xi:  reg F7logP     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogP   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,8]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,8]=r(sd) * _b[LSA2f_qje]

predict F7logPp, xb
gen F7logPnC=F7logPp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

esttab prod_C*, keep(LSA2f_qje   LSA2f) nostar t(2) b(3) brackets


* The standardized coefficients of Panel a of Table 4 
mat list stoSTD
***************************************************************************
matrix t_stat = J(2, 8, .)
local varlist LSA2f LSA2f_qje

forvalues h = 0/7 {
    local col = `h' + 1
    est restore prod_C`h'
    local row = 1
    foreach v of local varlist {
        matrix t_stat[`row', `col'] = _b[`v'] / _se[`v']
        local ++row
    }
}

local varnames LSA2f LSA2f_qje

forvalues i = 1/2 {
    local vname : word `i' of `varnames'
    di ""
    di "`vname'(Profit)"
    local row_coef ""
    local row_t ""

    forvalues j = 1/8 {
        local coef = string(stoSTD[`i', `j'], "%6.3f")
        local tval = string(t_stat[`i', `j'], "%5.2f")
        local row_coef = "`row_coef' `coef'"
        local row_t = "`row_t' [`tval']"
    }

    di "`row_coef'"
    di "`row_t'"
}


file open outfile using "t2a_results.txt", write replace
file write outfile "Panel A: Profit" _n

* Profit
forvalues i = 1/2 {
    local vname : word `i' of `varnames'
    file write outfile _n "`vname' (Profit)" _n
    local row_coef ""
    local row_t ""

    forvalues j = 1/8 {
        local coef = string(stoSTD[`i', `j'], "%6.3f")
        local tval = string(t_stat[`i', `j'], "%5.2f")
        local row_coef = "`row_coef' `coef'"
        local row_t = "`row_t' [`tval']"
    }

    file write outfile "`row_coef'" _n
    file write outfile "`row_t'" _n
}

file close outfile


