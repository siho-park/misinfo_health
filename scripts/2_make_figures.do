/*******************************************************************************
* SCRIPT: 2_make_figures.do
* PURPOSE: 
	- Make figures


*******************************************************************************/


**# Figure 2: Month of vaccination ---------------------------------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear
	
	
	* Vaccination timing
	qui count
	local total = `r(N)'
	
	
	collapse (count) id, by(H61)
	rename (H61 id) (month count)
	drop if missing(month)
	gen cumsum = sum(count)
	
	replace count = (count / `total')
	replace cumsum = (cumsum / `total')
	format count cumsum %12.1f
	
	twoway 	(bar count month, yaxis(1) ytitle("Monthly share", axis(1)) ylabel(0(0.1)0.3, angle(0) axis(1)) color(green%50)) ///
			(line cumsum month, yaxis(2) ytitle("Cumulative share", axis(2)) ylabel(0(0.3)0.9, angle(0) axis(2))) ///
			,xtitle("Month of vaccination (Year 2021)") xlabel(1(1)12) graphregion(color(white)) legend(off)
	
	graph export "$TRICYCLE/results/figures/f2_vaccine_month.png", replace width(1800)
	
	
}

**# Figure 3: Coefficients for individual misinformation questions -------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear

	
	* Standardize risk preference and education
	foreach var in rprefer edu{
		qui sum `var'
		gen `var'_std = (`var' - `r(mean)') / `r(sd)'
	}

	
	* Macros for specifications
	local spec1			"male married age edu_std"
	local spec2			"`spec1' rprefer_std impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Macros for outcome variables
	local misinfo_q		"nr_H28 nr_H29 nr_H26 nr_H24 nr_H31 nr_H21 nr_H22 nr_H30  nr_H25 nr_H27 nr_H23"

	
	* Add color in variable labels
	foreach num in 21 22 24 26 28 29 31{
		local original: variable label nr_H`num'
		label variable nr_H`num' 	"{bf:`original'}"
	}
	
	
	
	* Drop all the estimates
	estimates drop _all
	

	* Loop over each question
	foreach var in `misinfo_q'{
		
		* Regression with TODA FE
		qui reghdfe `var' `spec2', absorb(toda_name) vce(robust)
		estimates store `var'
		
		local rp_`var' = _b[rprefer_std]
		local edu_`var' = _b[edu_std]
		
	}
	
	
	* Average of 11 coefficients
	local rp_avg = (`rp_nr_H21' + `rp_nr_H22' + `rp_nr_H23' + `rp_nr_H24' + `rp_nr_H25' + `rp_nr_H26' + `rp_nr_H27' + `rp_nr_H28' + `rp_nr_H29' + `rp_nr_H30' + `rp_nr_H31') / 11
	local edu_avg = (`edu_nr_H21' + `edu_nr_H22' + `edu_nr_H23' + `edu_nr_H24' + `edu_nr_H25' + `edu_nr_H26' + `edu_nr_H27' + `edu_nr_H28' + `edu_nr_H29' + `edu_nr_H30' + `edu_nr_H31') / 11
	
	
	* Plot coefficients
	coefplot 	(*, keep(rprefer_std) asequation swapnames xline(0) graphregion(color(white)) mcolor(blue%50) ciopts(lcolor(blue%50))) ///
				(*, keep(edu_std) asequation swapnames mcolor(red%50) ciopts(lcolor(red%50)) ) ///
				, legend(order(2 "Standardized risk preference" 4 "Standardized years of schooling") position(6) row(1)) xsize(8) ///
				xtitle("Coefficients") xline(`rp_avg', lcolor(blue%20) lpattern(dash)) xline(`edu_avg', lcolor(red%20) lpattern(dash))
				

	* Export graph
	graph export "$TRICYCLE/results/figures/f3_misinfo_q_std.png", replace width(1800)
	
	
	
	
	
}
