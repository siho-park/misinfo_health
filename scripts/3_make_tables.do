/*******************************************************************************
* SCRIPT: 3_make_tables.do
* PURPOSE: 
	- Make tables


*******************************************************************************/

**# Table 2: Descriptive statistics --------------------------------------------
{
	
	* Load dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/baseline", clear
		
	
	* Normalize
	foreach var of varlist score*{
		qui sum `var'
		local max = r(max)
		replace `var' = `var' / `max'
	}
	
	
	* Variable macro
	local ses 			"male married age edu"
	local covid			"test vaccine"
	local prevention	"prevention H32 H33 H34 H35"
	local labor			"work_ecq work_gcq work_recent second_ecq second_gcq second_recent"
	local misinfo		"misinfo_nr nr_H21 nr_H22 nr_H24 nr_H26 nr_H28 nr_H29 nr_H31 nr_H23 nr_H25 nr_H27 nr_H30"
	local experiment	"rprefer impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	local baseline		"`ses' `experiment'"
	local midline 		"`covid' `prevention' `labor' `misinfo'"
	
	
	* Prepare result frame
	set_col, name("varname mean sd N")
	
	
	* Baseline variables
	foreach i of numlist 1/`=wordcount("`baseline'")'{
		
		
		* Set observation number
		set_obs, line(`=wordcount("`baseline'")')
		
		
		* Variable
		local var: word `i' of `baseline'
		local label: variable label `var'

		* Format
		if strpos("`var'", "age"){
			local format "%12.2f"
		}
		else if strpos("`var'", "income"){
			local format "%12.0f"
		}
		else{
			local format	"%12.3f"
		}
		
		
		* Label
		write_name, name("`label'") line(`i')
		
		* Summarize
		qui sum `var'
		
		
		* Mean
		local mean = string(`r(mean)', "`format'")
		write_est, name("`mean'") line(`i') outcome(mean)
		
		
		* SD
		local sd = string(`r(sd)', "`format'")
		write_est, name("`sd'") line(`i') outcome(sd)
		
		
		* N
		qui count if !missing(`var')
		write_est, name("`r(N)'") line(`i') outcome(N)
	}
	
	
	* Load master dataset
	use "$TRICYCLE/processed/master", clear
	
	
	
	* Midline variables
	foreach i of numlist 1/`=wordcount("`midline'")'{
		
		
		* Set observation number
		set_obs, line(`= wordcount("`baseline'") + wordcount("`midline'")')
		
		
		* Variable
		local j = `=`i' + wordcount("`baseline'")'
		local var: word `i' of `midline'
		local label: variable label `var'

		* Format
		if strpos("`var'", "age"){
			local format "%12.2f"
		}
		else{
			local format	"%12.3f"
		}
		
		
		* Label
		write_name, name("`label'") line(`j')
		
		* Summarize
		qui sum `var'
		
		
		* Mean
		local mean = string(`r(mean)', "`format'")
		write_est, name("`mean'") line(`j') outcome(mean)
		
		
		* SD
		local sd = string(`r(sd)', "`format'")
		write_est, name("`sd'") line(`j') outcome(sd)
		
		
		* N
		qui count if !missing(`var')
		write_est, name("`r(N)'") line(`j') outcome(N)
	}
	
	
	

	* Panel name
	frame change result
	local N = _N
	set_obs, line(`=`N' + 6')
	write_name, name("Demographics") line(`=`N' + 1')
	write_name, name("Experiment") line(`=`N' + 2')
	write_name, name("COVID testing and vaccination") line(`=`N' + 3')
	write_name, name("Preventive behavior") line(`=`N' + 4')
	write_name, name("Labor supply") line(`=`N' + 5')
	write_name, name("Misinformation") line(`=`N' + 6')
	
	
	* Format table
	frame change result
	gen order = _n
	replace order = 0.5 if order == `=`N' + 1'
	replace order = 4.5 if order == `=`N' + 2'
	replace order = 13.5 if order == `=`N' + 3'
	replace order = 15.5 if order == `=`N' + 4'
	replace order = 20.5 if order == `=`N' + 5'
	replace order = 26.5 if order == `=`N' + 6'
	sort order
	drop order

	replace varname = "\hspace{1em}" + varname if !missing(mean)
	
	local N = _N
	set_obs, line(`=`N' + 2')
	write_name, name("\textbf{Panel A. First survey}") line(`=`N' + 1')
	write_name, name("\textbf{Panel B. Second survey}") line(`=`N' + 2')
	frame change result
	gen order = _n
	replace order = 0.5 if order == `=`N' + 1'
	replace order = 15.5 if order == `=`N' + 2'
	sort order
	drop order
	
	
	* Var labels
	label variable mean 	"Mean"
	label variable sd 		"Standard deviation"
	label variable N 		"N"
	

	* Title and footnote
	local title 	"Descriptive statistics"
	local fn	"Notes: This table reports descriptive statistics of all the variables used in this study."
	local fn	"`fn' Risk preference, impatience and test score variables are within unit interval."	
	local fn 	"`fn' The outcome variable equals one for an incorrect answer, indicating misinformed belief."
	local fn	"`fn' Hence, the closer it is to 1, the more people are likely to believe in misinformation."

	
	texsave using "$TRICYCLE/results/tables/t2_descriptive.tex", varlabels nofix title("`title'") footnote("`fn'") size("footnotesize") hlines(1 17) replace
	
	
}

**# Table 3: Job characteristics during the COVID-19 pandemic ------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear

	
	* Prepare result frame
	set_col, name("var ecq_count ecq_percent gcq1_count gcq1_percent gcq2_count gcq2_percent")
	set_obs, line(7)
	write_name, name("Driver of any vehicle") line(1)
	write_name, name("\hspace{2em} Delivery worker") line(2)
	write_name, name("Construction worker") line(3)
	write_name, name("Street vendor/shop") line(4)
	write_name, name("Daily laborer") line(5)
	write_name, name("Technician") line(6)
	write_name, name("Total who worked") line(7)
	
	
	
	* ECQ 
	{
	di "Total who worked"
	qui count if L1 == 1
	local total = `r(N)'
	write_est, outcome(ecq_count) line(7) name("`total'")
	write_est, outcome(ecq_percent) line(7) name("100")
	
	
	di "Driver of any vehicle: `r(N)'"
	qui count if L2 == 4
	local count = `r(N)'
	write_est, outcome(ecq_count) line(1) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(1) name("`percent'")
	
	
	
	di "Delivery worker"
	qui count if L3 == 1
	local count = `r(N)'
	write_est, outcome(ecq_count) line(2) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(2) name("`percent'")
	
	
		
	di "Construction worker"
	qui count if L2 == 11
	local count = `r(N)'
	write_est, outcome(ecq_count) line(3) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(3) name("`percent'")
	
	
	
	di "Street vendor/shop"
	qui count if L2 == 15
	local count = `r(N)'
	write_est, outcome(ecq_count) line(4) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(4) name("`percent'")
	

	
	di "Daily laborer"
	qui count if L2 == 9
	local count = `r(N)'
	write_est, outcome(ecq_count) line(5) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(5) name("`percent'")
	
	
		
	di "Technician"
	qui count if L2 == 2
	local count = `r(N)'
	write_est, outcome(ecq_count) line(6) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(ecq_percent) line(6) name("`percent'")
	}
	

	
	* GCQ I
	{
	di "Total who worked"
	qui count if L8 == 1
	local total = `r(N)'
	write_est, outcome(gcq1_count) line(7) name("`total'")
	write_est, outcome(gcq1_percent) line(7) name("100")
	
	
	di "Driver of any vehicle: `r(N)'"
	qui count if L9 == 4
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(1) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(1) name("`percent'")
	
	
	
	di "Delivery worker"
	qui count if L10 == 1
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(2) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(2) name("`percent'")
	
	
		
	di "Construction worker"
	qui count if L9 == 11
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(3) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(3) name("`percent'")
	
	
	
	di "Street vendor/shop"
	qui count if L9 == 15
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(4) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(4) name("`percent'")
	

	
	di "Daily laborer"
	qui count if L9 == 9
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(5) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(5) name("`percent'")
	
	
		
	di "Technician"
	qui count if L9 == 2
	local count = `r(N)'
	write_est, outcome(gcq1_count) line(6) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq1_percent) line(6) name("`percent'")
	}
	
	
	
	* GCQ II
	{
	di "Total who worked"
	qui count if L15 == 1
	local total = `r(N)'
	write_est, outcome(gcq2_count) line(7) name("`total'")
	write_est, outcome(gcq2_percent) line(7) name("100")
	
	
	di "Driver of any vehicle: `r(N)'"
	qui count if L16 == 4
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(1) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(1) name("`percent'")
	
	
	
	di "Delivery worker"
	qui count if L17 == 1
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(2) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(2) name("`percent'")
	
	
		
	di "Construction worker"
	qui count if L16 == 11
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(3) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(3) name("`percent'")
	
	
	
	di "Street vendor/shop"
	qui count if L16 == 15
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(4) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(4) name("`percent'")
	

	
	di "Daily laborer"
	qui count if L16 == 9
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(5) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(5) name("`percent'")
	
	
		
	di "Technician"
	qui count if L16 == 2
	local count = `r(N)'
	write_est, outcome(gcq2_count) line(6) name("`count'")
	
	local percent = 100 * `count' / `total'
	local percent = string(`percent', "%12.1f")
	write_est, outcome(gcq2_percent) line(6) name("`percent'")
	}
	
	
	* Variable labels
	frame change result
	label var var "Main occupation"
	
	label var ecq_count "Count"
	label var gcq1_count "Count"
	label var gcq2_count "Count"
	
	label var ecq_percent "Percent"
	label var gcq1_percent "Percent"
	label var gcq2_percent "Percent"
	
	
	* Latex output
	local title "Job characteristics during the COVID-19 pandemic"
	
	local headerlines "& \multicolumn{2}{c}{ECQ (March-May 2020)} & \multicolumn{2}{c}{GCQ I (June 2020-Mar 2021)} & \multicolumn{2}{c}{GCQ II (April 2021-)} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}"
	
	local fn "Notes: This table reports the type of occupations held by initial tricycle drivers during the ECQ, GCQ I, and GCQ II periods."
	local fn "`fn' Tricycle driving belongs to the category, Driver of any vehicle."
	local fn "`fn' Delivery worker is a sub-category of driver of any vehicle and refers to those delivering take-out foods."
	local fn "`fn' At the first baseline summary, no tricycle drivers were delivery workers."
	   
	
	texsave using "$TRICYCLE/results/tables/t3_jobs.tex", autonumber varlabels hlines(-1) title("`title'") headerlines("`headerlines'") footnote("`fn'") nofix size("footnotesize") replace
	
 
}

**# Table 4: Economic Correlates of belief in misinformation -------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear

	
	* Macros for specifications
	gen age10 = age / 10
	gen age10_sq = (age^2) / 100
	gen log_ind = log(income_ind)
	gen log_hh = log(income_hh)
	
	local spec1			"male married age10 age10_sq edu"
	local spec2			"`spec1' rprefer impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Tempfile
	tempfile temp
	
	* Group mean
	qui sum misinfo_nr
	local gmean = `r(mean)'
	

	* Regressions with different specifications
	qui reghdfe misinfo_nr `spec1', absorb(toda_name) vce(robust)
	regsave using `temp', table(spec1, parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean')  replace
	
	qui reghdfe misinfo_nr `spec2', absorb(toda_name) vce(robust)
	regsave using `temp', table(spec2, parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean')  append

	
	* Turn to result frame
	frame change result
	use `temp', clear
	
	
	
	* Format the table
	gen keep_var = .
	replace keep_var = 1 if strpos(var, "_coef") | strpos(var, "_stderr")
	replace keep_var = 1 if inlist(var, "N")
	replace keep_var = 0 if strpos(var, "_cons")
	keep if keep_var == 1
	drop keep_var
	drop if var == "Mean_stderr"
		
	replace var = subinstr(var, "_coef", "", 1)
	replace var = "" if strpos(var, "_stderr")
	replace var = subinstr(var, "_", " ", 1)
	
	replace var = "Risk preference"			if var == "rprefer"
	replace var = "Impatience"				if var == "impatience23"
	replace var = "Stochastic dominance 1"	if var == "sd1"
	replace var = "Stochastic dominance 2"	if var == "sd2"
	replace var = "CCEI (risk domain)"		if var == "ccei risk"
	replace var = "CCEI (time domain)" 		if var == "ccei time23"
	replace var = "Years of education"		if var == "edu"
	replace var = "Age/10"					if var == "age10"
	replace var = "(Age/10)\(^{2}\)"		if var == "age10 sq"
	replace var = "log(Individual income)"	if var == "log ind"
	replace var = "log(Household income)"	if var == "log hh"
	replace var = "Raven's test score"		if var == "score raven"
	replace var = "Numeracy score"			if var == "score numeracy"
	replace var = "Financial literacy score" if var == "score financial"
	
	foreach row in 1 3 23 25{
		replace var = proper(var) in `row'
	}
	
	
	* Add TODA FE row
	local N = _N
	set_obs, line(`=`N' + 1')
	write_name, name("TODA FE") line(`=`N' + 1')
	
	frame change result
	foreach var of varlist spec*{
		replace `var' = "Y" in `=`N' + 1'
	}
	
	

	* Output in latex
	local title "Economic correlates of belief in misinformation"
	
	local headerlines "\cmidrule(lr){2-3}  & \multicolumn{2}{c}{Outcome var: Misinformation index}"
	
	local fn "Notes: This table reports association between belief in misinformation and individual characteristics."
	local fn "`fn' Risk preference, impatience and test score variables are within unit interval. Age variable is divided by 10 to make coefficients larger. The marginal effect of 1 year increase in age is one tenth of the reported coefficients."
	local fn "`fn' Both specifications include TODA fixed effects."
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave using "$TRICYCLE/results/tables/t4_correlates.tex", autonumber nonames hlines(-3) title("`title'") headerlines("`headerlines'") footnote("`fn'") nofix size("footnotesize") replace
	
	
	
}
	
**# Table 5-7: Misinformation and health behaviors -----------------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear

	
	* Macros for specifications
	local spec1 		"misinfo_nr"
	local spec2			"`spec1' male married i.age i.edu"
	local spec3			"`spec2' rprefer impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Macros for outcome variables
	local health		"test vaccine prevention"
	local labor			"work_ecq work_gcq work_recent"
	local prevention_q	"H32 H33 H34 H35"
	
	
	* Tempfile
	tempfile temp
	
	
	* Regressions
	local replace "replace"
	foreach var in `health' `labor' `prevention_q'{
		
		* Group mean
		qui sum `var'
		local gmean = `r(mean)'
		
		
		* Spec 1: misinfo + TODA FE
		qui reghdfe `var' `spec1', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var'_spec1, parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
		local replace "append"
		
		
		* Spec 2: misinfo + demographic + TODA FE
		qui reghdfe `var' `spec2', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var'_spec2, parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
		
		
		* Spec 3: misinfo + demographic + experiment + TODA FE
		qui reghdfe `var' `spec3', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var'_spec3, parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
	}
	
	
	* Turn to result frame
	frame change result
	use `temp', clear
	

	* Format the table
	gen keep_var = .
	replace keep_var = 1 if strpos(var, "misinfo") | strpos(var, "Mean")
	
	replace keep_var = 1 if inlist(var, "N")
	keep if keep_var == 1
	drop keep_var
	
	drop if var == "Mean_stderr"
	
	replace var = subinstr(var, "_coef", "", 1)
	replace var = "" if strpos(var, "_stderr")
	replace var = subinstr(var, "_", " ", 1)
	
	local N = _N
	set obs `=`N' + 4'
	replace var = "Controls" in `=`N' + 1'
	replace var = "\hspace{1em} TODA FE" in `=`N' + 2'
	replace var = "\hspace{1em} Demographic" in `=`N' + 3'
	replace var = "\hspace{1em} Experimental" in `=`N' + 4'
	
	foreach var of varlist *spec1{
		replace `var' = "Y" in `=`N' + 2'
	}
	
	foreach var of varlist *spec2{
		replace `var' = "Y" in `=`N' + 2'
		replace `var' = "Y" in `=`N' + 3'
	}
	
	foreach var of varlist *spec3{
		replace `var' = "Y" in `=`N' + 2'
		replace `var' = "Y" in `=`N' + 3'
		replace `var' = "Y" in `=`N' + 4'
	}
	
	
	replace var = "Misinfo index"	if var == "misinfo nr"
	
	foreach var of varlist H32*{
		label variable `var' 		"Avoid social gathering"
	}
	foreach var of varlist H33*{
		label variable `var' 		"Wear mask"
	}
	foreach var of varlist H34*{
		label variable `var' 		"Wash hands often"
	}
	foreach var of varlist H35*{
		label variable `var' 		"Sneeze into elbox"
	}
	
	
	* Table 6
	local title "Misinformation and preventive health behaviors"
	
	local fn "Notes: This table reports association between belief in misinformation and four types of preventive health behaviors."
	local fn "`fn' All specifications include TODA fixed effects, and demographic and experimental control variables reported in Table \ref{tab:descriptive}."
	local fn "`fn' Preventive behavior index is the average of the four types of preventive behaviors."
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	texsave var H3?_spec3 using "$TRICYCLE/results/tables/t6_prevention_q.tex", autonumber varlabels hlines(2 4) title("`title'") footnote("`fn'") nofix size("footnotesize") replace
	
	
	* Table 5
	local title "Testing"
	texsave var test* using "$TRICYCLE/results/tables/t5_testing.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace
	
	local title "Vaccination"
	texsave var vaccine* using "$TRICYCLE/results/tables/t5_vaccination.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace
	
	local title "Preventive behaviors"
	texsave var prevention* using "$TRICYCLE/results/tables/t5_prevention.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace

	
	* Table 7
	local title "Labor supply during ECQ"
	texsave var work_ecq*  using "$TRICYCLE/results/tables/t7_ecq.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace
	
	local title "Labor supply during GCQ I"
	texsave var work_gcq*  using "$TRICYCLE/results/tables/t7_gcq1.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace
	
	local title "Labor supply during GCQ II"
	texsave var work_recent*  using "$TRICYCLE/results/tables/t7_gcq2.tex", autonumber nonames hlines(2 4) title("`title'") nofix  size("footnotesize") replace
	
}

**# Table A1 : Attrition -------------------------------------------------------
{
	
	* Load the baseline data
	frame result: clear
	frame change default
	use "$TRICYCLE/processed/baseline", clear


	* Merge midline data
	merge 1:1 id using "$TRICYCLE/data/midline", keep(master match)
	
	
	* Keep relevant variables
	local id 		"id "
	local demo 		"male age edu married"
	local score 	"score_raven score_numeracy score_financial"
	local ccei 		"ccei_risk ccei_time23"
	local risk 		"rprefer"
	local time		"impatience23 present_bias future_bias"
	
	keep `id' `demo' `score' `ccei' `risk' `time' _merge
	
	
	* Samples in both rounds
	gen both = (_merge == 3)
	drop _merge
	
	
	
	* Create result frame
	set_col, name("var both attrition diff")
	
	
	* Loop over baseline variables
	local outcome "`demo' `score' `risk' `time' `ccei'"
	foreach i of numlist 1/`=wordcount("`outcome'")'{
		
		
		* Variable
		local var: word `i' of `outcome'
		
		
		* Line
		set_obs, line(`=2 * `i'')
		
		
		* Var label
		local label: variable label `var'
		
		
		* Write name
		write_name, name("`label'") line(`=2 * `i' - 1')
		
		
		* Format
		if strpos("`var'", "age"){
			local format "%12.2f"
		}
		else{
			local format	"%12.3f"
		}
		
		
		* Mean and standard deviation
		qui sum `var' if both == 1
		local mean = string(`r(mean)', "`format'")
		local sd = "(" + string(`r(sd)', "`format'") + ")"
		write_est, outcome(both) name("`mean'") line(`=2 * `i' - 1')
		write_est, outcome(both) name("`sd'") line(`=2 * `i'')
		
		qui sum `var' if both == 0
		local mean = string(`r(mean)', "`format'")
		local sd = "(" + string(`r(sd)', "`format'") + ")"
		write_est, outcome(attrition) name("`mean'") line(`=2 * `i' - 1')
		write_est, outcome(attrition) name("`sd'") line(`=2 * `i'')
		
		
		* Difference
		qui reg `var' both, robust
		write_beta, outcome(diff) ind(both) line(`=2 * `i' - 1') df(`e(df_r)') format("`format'")
		
	}
	
	
	* N
	frame change result
	local N = _N
	set_obs, line(`= `N' + 1')
	write_name, name("N") line(`=`N' + 1')
	
	qui count if both == 1
	write_est, outcome(both) name("`r(N)'") line(`=`N' + 1')
	
	qui count if both == 0
	write_est, outcome(attrition) name("`r(N)'") line(`=`N' + 1')
	
	
	* Variable labels
	frame change result
	label variable both 		"1st \& 2nd survey"
	label variable attrition 	"Only 1st survey"
	label variable diff			"Difference"
	
	
	* Save as a latex file
	local title 	"Attrition"
	
	local fn	"Notes: This table characterizes sample attrition by comparing those who were included in both 1st and 2nd survey with those who dropped out in the 2nd survey."
	local fn	"`fn' The mean and standard deviations of the entire sample are reported in Table \ref{tab:descriptive}."	
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	

	texsave * using "$TRICYCLE/results/tables/ta1_attrition.tex", autonumber varlabels nofix title("`title'") footnote("`fn'") size("footnotesize") hlines(-1) replace
	
	
	
}

**# Table A2 and A4 ------------------------------------------------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear


	* Log of income variables
	gen log_ind = log(income_ind)
	gen log_hh = log(income_hh)
	
	local health		"test vaccine prevention"
	local labor			"work_ecq work_gcq work_recent"
	local demo			"male married log_ind log_hh i.age i.edu "
	local experiment	"rprefer impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Tempfile for storing results
	tempfile temp
	
	
	
	* Regressing labor supply on experimental measures
	local replace "replace"
	foreach var in `health' `labor'{
		
		* Mean
		sum `var'
		local gmean = `r(mean)'
		
		
		* Regression
		reghdfe `var' `experiment' `demo', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var', parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
		
		local replace "append"
		
	}
	
	
	
	* Store regression results in the result frame
	frame change result
	use `temp', clear
	
	
	* Keep relevant results
	gen keep_var = .
	replace keep_var = 1 if strpos(var, "rprefer") | strpos(var, "impatience") | strpos(var, "Mean")
	
	replace keep_var = 1 if inlist(var, "N")
	keep if keep_var == 1
	drop keep_var
	
	drop if var == "Mean_stderr"
	
	replace var = subinstr(var, "_coef", "", 1)
	replace var = "" if strpos(var, "_stderr")
	replace var = subinstr(var, "_", " ", 1)
	
	
	* Add additional regression information
	local N = _N
	set obs `=`N' + 4'
	replace var = "Controls" in `=`N' + 1'
	replace var = "\hspace{1em} TODA FE" in `=`N' + 2'
	replace var = "\hspace{1em} Demographic" in `=`N' + 3'
	replace var = "\hspace{1em} Experimental" in `=`N' + 4'
	
	foreach var of varlist test vaccine prevention work*{
		replace `var' = "Y" in `=`N' + 2'/`=`N'+4'
	}
	
	
	replace var = "Risk preference"	if var == "rprefer"
	replace var = "Impatience"	if var == "impatience23"
	
	
	* Variable labels
	label var test			"COVID test"
	label var vaccine		"COVID vaccine"
	label var prevention	"Preventive behavior"
	
	label var work_ecq		"ECQ"
	label var work_gcq		"GCQ I"
	label var work_recent	"GCQ II"
	
	
	
	* Export as a Latex file
	local title 	"Association between health behaviors and experimental measures"
	
	local fn	"Notes: This table reports association between labor supply during COVID-19 pandemic and risk and time preference (impatience) measures."
	local fn	"`fn' All specifications include TODA fixed effects and the full set of demographic and experimental controls (see Table \ref{tab:descriptive} in the main text)."	
	local fn 	"`fn' Only the coefficients of risk preference and impatience are reported."
	local fn 	"`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var test vaccine prevention using "$TRICYCLE/results/tables/ta2_health.tex", autonumber varlabels title("`title'") footnote("`fn'") hlines(4) nofix size("footnotesize") replace
	
	
	local title 	"Association between labor supply and experimental measures"
	
	local fn	"Notes: This table reports association between labor supply during COVID-19 pandemic and risk and time preference (impatience) measures."
	local fn	"`fn' All specifications include TODA fixed effects and the full set of demographic and experimental controls (see Table \ref{tab:descriptive} in the main text)."	
	local fn 	"`fn' Only the coefficients of risk preference and impatience are reported."
	local fn 	"`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	texsave var work_ecq work_gcq work_recent  using "$TRICYCLE/results/tables/ta4_labor.tex", autonumber varlabels title("`title'") footnote("`fn'") hlines(4) nofix size("footnotesize") replace
	
	
}

**# Table A3 and A5 ------------------------------------------------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear


	* Log of income variables
	gen log_ind = log(income_ind)
	gen log_hh = log(income_hh)
	
	local health		"test vaccine prevention"
	local labor			"work_ecq work_gcq work_recent"
	local demo			"male married log_ind log_hh i.age i.edu "
	local experiment	"ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Tempfile for storing results
	tempfile temp
	
	
	
	* Regressing labor supply on experimental measures
	local replace "replace"
	foreach var in `health' `labor' {
		
		* Mean
		sum `var'
		local gmean = `r(mean)'
		
		
		* Regression
		ivreghdfe `var' (misinfo_nr = rprefer impatience23) `experiment' `demo', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var', parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
		
		local replace "append"
		
	}
	
	
	
	* Store regression results in the result frame
	frame change result
	use `temp', clear
	
	
	* Keep relevant results
	gen keep_var = .
	replace keep_var = 1 if strpos(var, "misinfo_nr") | strpos(var, "Mean")
	
	replace keep_var = 1 if inlist(var, "N")
	keep if keep_var == 1
	drop keep_var
	
	drop if var == "Mean_stderr"
	
	replace var = subinstr(var, "_coef", "", 1)
	replace var = "" if strpos(var, "_stderr")
	replace var = subinstr(var, "_", " ", 1)
	
	
	* Add additional regression information
	local N = _N
	set obs `=`N' + 4'
	replace var = "Controls" in `=`N' + 1'
	replace var = "\hspace{1em} TODA FE" in `=`N' + 2'
	replace var = "\hspace{1em} Demographic" in `=`N' + 3'
	replace var = "\hspace{1em} Experimental" in `=`N' + 4'
	
	
	foreach var of varlist test vaccine prevention work*{
		replace `var' = "Y" in `=`N' + 2'/`=`N'+4'
	}
	
	
	replace var = "Misinfo index"	if var == "misinfo nr"
	
	
	* Variable labels
	label var test			"COVID test"
	label var vaccine		"COVID vaccine"
	label var prevention	"Preventive behavior"
	
	label var work_ecq		"ECQ"
	label var work_gcq		"GCQ I"
	label var work_recent	"GCQ II"
	
	
	
	* Export as a Latex file
	local title 	"Association between health behaviors and misinformation instrumented by risk/time preference"
	
	local fn	"Notes: This table reports association between health behaviors during COVID-19 pandemic and misinformation index using two-stage least square regression."
	local fn	"`fn' Misinformation index is instrumented by the risk and time preference (impatience) measures."	
	local fn 	"`fn' All specifications include TODA fixed effects and the full set of controls described in Table \ref{tab:descriptive} of the main text."
	local fn 	"`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var test vaccine prevention using "$TRICYCLE/results/tables/ta3_health.tex", autonumber varlabels  title("`title'") footnote("`fn'") hlines(4) nofix size("footnotesize") replace
	
	
	local title 	"Association between labor supply and misinformation instrumented by risk/time preference"
	
	local fn	"Notes: This table reports association between labor supply during COVID-19 pandemic and misinformation index using two-stage least square regression."
	local fn	"`fn' Misinformation index is instrumented by the risk and time preference (impatience) measures."	
	local fn 	"`fn' All specifications include TODA fixed effects and the full set of controls described in Table \ref{tab:descriptive} of the main text."
	local fn 	"`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var work* using "$TRICYCLE/results/tables/ta5_labor.tex", autonumber varlabels title("`title'") footnote("`fn'") hlines(4) nofix size("footnotesize") replace
	
	
	
	
}

**# Table A6 - A8 --------------------------------------------------------------
{
	
	* Load the dataset
	frame change default
	frame result: clear
	use "$TRICYCLE/processed/master", clear

	
	* Log of income variables
	gen log_ind = log(income_ind)
	gen log_hh = log(income_hh)
	
	
	* Macros for specifications
	local spec1 		"nr_H28 nr_H29 nr_H26 nr_H24 nr_H31 nr_H21 nr_H22 nr_H30  nr_H25 nr_H27 nr_H23"
	local spec2			"`spec1' male married i.age i.edu log_ind log_hh"
	local spec3			"`spec2' rprefer impatience23 ccei_risk ccei_time23 present_bias future_bias score_raven score_numeracy score_financial"
	
	
	* Macros for outcome variables
	local health		"test vaccine prevention"
	local labor			"work_ecq work_gcq work_recent"
	local prevention_q	"H32 H33 H34 H35"
	
	
		* Tempfile
	tempfile temp
	
	
	* Regressions
	local replace "replace"
	foreach var in `health' `labor' `prevention_q'{
		
		* Group mean
		qui sum `var'
		local gmean = `r(mean)'
		

		* Spec 3: misinfo + demographic + experiment + TODA FE
		qui reghdfe `var' `spec3', absorb(toda_name) vce(robust)
		regsave using `temp', table(`var', parentheses(stderr) format(%12.3f) asterisk()) detail(all) addvar(Mean, `gmean') `replace'
		local replace "append"
	}
	
	
	* Turn to result frame
	frame change result
	use `temp', clear
	
	
	
	
	* Format the table
	gen keep_var = .
	replace keep_var = 1 if strpos(var, "nr") | strpos(var, "Mean")
	
	replace keep_var = 1 if inlist(var, "N")
	keep if keep_var == 1
	drop keep_var
	
	drop if var == "Mean_stderr"
	
	replace var = subinstr(var, "_coef", "", 1)
	replace var = "" if strpos(var, "_stderr")
	replace var = subinstr(var, "_", " ", 1)
	
	local N = _N
	set obs `=`N' + 4'
	replace var = "Controls" in `=`N' + 1'
	replace var = "\hspace{1em} TODA FE" in `=`N' + 2'
	replace var = "\hspace{1em} Demographic" in `=`N' + 3'
	replace var = "\hspace{1em} Experimental" in `=`N' + 4'
	

	foreach var of varlist test-H35{
		replace `var' = "Y" in `=`N' + 2'
		replace `var' = "Y" in `=`N' + 3'
		replace `var' = "Y" in `=`N' + 4'
	}
	
	
	
	* Question labels
	replace var = "\textbf{Vaccine causes infertility}" 	if var == "nr H28"
	replace var = "\textbf{Vaccine contains magnet}" 		if var == "nr H29"
	replace var = "\textbf{Vaccine is not effective}" 		if var == "nr H26"
	replace var = "\textbf{Vaccine suppress immune system}" if var == "nr H24"
	replace var = "\textbf{Vaccine contains fetus}" 		if var == "nr H31"
	replace var = "\textbf{Vaccine can change DNA}" 		if var == "nr H21"
	replace var = "\textbf{Vaccine is fake}" 				if var == "nr H22"
	replace var = "Vaccine reduces death" 					if var == "nr H30"
	replace var = "Mask helps" 								if var == "nr H25"
	replace var = "Can still pass COVID after vaccine" 		if var == "nr H27"
	replace var = "Vaccine has side effects" 				if var == "nr H23"
	
	
	label variable test		"Test"
	label variable vaccine		"Vaccine"
	label variable prevention		"Preventive behavior index"
	label variable work_ecq		"ECQ"
	label variable work_gcq		"GCQ I"
	label variable work_recent		"GCQ II"
	
	label variable H32		"Avoid social gathering"
	label variable H33		"Wear mask"
	label variable H34		"Wash hands often"
	label variable H35		"Sneeze into elbow"
	
	
	
	
	* Output in latex
	local title "Individual misinformation questions and health behaviors"
	
	local fn "Notes: This table reports association between individual misinformation questions and health behaviors during COVID-19 pandemic."
	local fn "`fn' All misinformation questions equal one for an incorrect answer, indicating misinformed belief."
	local fn "`fn' Hence, it equals one when answered Yes to incorrect statements and No to correct statements."
	local fn "`fn' Questions in bold are wrong statements and the rest are true statements."
	local fn "`fn' All specifications control TODA fixed effects and the set of demographic and experimental variables, reported in Table \ref{tab:descriptive}."
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var test vaccine prevention using "$TRICYCLE/results/tables/ta6_health.tex", autonumber varlabels title("`title'") footnote("`fn'") hlines(22) nofix size("footnotesize") replace
	
	
	local title "Individual misinformation questions and preventive health behaviors"
	
	local fn "Notes: This table reports association between individual misinformation questions and preventive health behaviors during COVID-19 pandemic."
	local fn "`fn' All misinformation questions equal one for an incorrect answer, indicating misinformed belief."
	local fn "`fn' Hence, it equals one when answered Yes to incorrect statements and No to correct statements."
	local fn "`fn' Questions in bold are wrong statements and the rest are true statements."
	local fn "`fn' All specifications control TODA fixed effects and the set of demographic and experimental variables, reported in Table \ref{tab:descriptive}."
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var H* using "$TRICYCLE/results/tables/ta7_prevention.tex", autonumber varlabels hlines(22) title("`title'") footnote("`fn'") nofix size("footnotesize") replace
	
	
	local title "Individual misinformation questions and labor supply"
	
	local fn "Notes: This table reports association between individual misinformation questions and labor supply during COVID-19 pandemic."
	local fn "`fn' All misinformation questions equal one for an incorrect answer, indicating misinformed belief."
	local fn "`fn' Hence, it equals one when answered Yes to incorrect statements and No to correct statements."
	local fn "`fn' Questions in bold are wrong statements and the rest are true statements."
	local fn "`fn' All specifications control TODA fixed effects and the set of demographic and experimental variables, reported in Table \ref{tab:descriptive}."
	local fn "`fn' Robust standard errors are used. A */**/*** indicates significance at the 10/5/1\% levels."
	
	
	texsave var work* using "$TRICYCLE/results/tables/ta8_labor.tex", autonumber varlabels hlines(22) title("`title'") footnote("`fn'") nofix size("footnotesize") replace
	
	
	
	
	
	
	
}
