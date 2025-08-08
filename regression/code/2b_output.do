clear all
cd "/Users/wenqian/Desktop/ra/Aug1/data"

use "firm_data.dta", clear
merge 1:1 permno year using qje_data.dta
drop if _merge == 2
drop _merge
replace qje_Af=0 if missing(qje_Af)
replace qje_AfI=0 if missing(qje_AfI)

tsset permno year
gen F0logY=(logY)-L.logY
gen F1logY=(F1.logY)-L.logY
gen F2logY=(F2.logY)-L.logY
gen F3logY=(F3.logY)-L.logY
gen F4logY=(F4.logY)-L.logY
gen F5logY=(F5.logY)-L.logY
gen F6logY=(F6.logY)-L.logY
gen F7logY=(F7.logY)-L.logY
 
gen LlogY=L.logY

* Innovation by competing firms
gen LSA2f_qje=L.qje_Af 

* Innovation by the firm
gen LSA2f=L.Af

* This matrix holds the standardized coefficients (Innovation scaled to unit standard deviation)
matrix stoSTD = J(2,8,.) 

eststo prod_C0: qui xi: cluster2  F0logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   ,  fcluster(permno) tcluster(year)  
qui xi:  reg F0logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   
qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,1]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,1]=r(sd) * _b[LSA2f_qje]

predict F0logYp, xb
gen F0logYnC=F0logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C1: qui xi: cluster2  F1logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year)   
qui xi:  reg F1logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,2]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,2]=r(sd) * _b[LSA2f_qje]

predict F1logYp, xb
gen F1logYnC=F1logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C2: qui xi: cluster2  F2logY    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year)   
qui xi:  reg F2logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,3]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,3]=r(sd) * _b[LSA2f_qje]

predict F2logYp, xb
gen F2logYnC=F2logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C3: qui xi: cluster2  F3logY    LlogK LlogH     i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year)  
qui xi:  reg F3logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,4]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,4]=r(sd) * _b[LSA2f_qje]

predict F3logYp, xb
gen F3logYnC=F3logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C4: qui xi: cluster2  F4logY   LlogK  LlogH     i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret   LlogY ,  fcluster(permno) tcluster(year)   
qui xi:  reg F4logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,5]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,5]=r(sd) * _b[LSA2f_qje]

predict F4logYp, xb
gen F4logYnC=F4logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f


eststo prod_C5: qui xi: cluster2  F5logY    LlogK   LlogH   i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year) 
qui xi:  reg F5logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,6]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,6]=r(sd) * _b[LSA2f_qje]

predict F5logYp, xb
gen F5logYnC=F5logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C6: qui xi: cluster2  F6logY    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year)   
qui xi:  reg F6logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,7]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,7]=r(sd) * _b[LSA2f_qje]

predict F6logYp, xb
gen F6logYnC=F6logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

eststo prod_C7: qui xi: cluster2  F7logY    LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY ,  fcluster(permno) tcluster(year)  
qui xi:  reg F7logY     LlogK  LlogH    i.year i.indcd LSA2f_qje   LSA2f  Lvol_iret  LlogY   

qui sum    LSA2f if e(sample)==1,d
matrix stoSTD[1,8]=r(sd) * _b[LSA2f]

qui sum    LSA2f_qje if e(sample)==1,d
matrix stoSTD[2,8]=r(sd) * _b[LSA2f_qje]

predict F7logYp, xb
gen F7logYnC=F7logYp - _b[LSA2f_qje]*LSA2f_qje - _b[LSA2f]*LSA2f

esttab prod_C*, keep(LSA2f_qje   LSA2f) nostar t(2) b(3) brackets

* The standardized coefficients of Panel b of Table 4 
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
    di "`vname'(Output)"
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


file open outfile using "t2b_results.txt", write replace
file write outfile "Panel B: Output" _n

* Output
forvalues i = 1/2 {
    local vname : word `i' of `varnames'
    file write outfile _n "`vname' (Output)" _n
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

