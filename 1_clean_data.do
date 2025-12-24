/*******************************************************************************
* SCRIPT: 1_clean_data.do
* PURPOSE: 
	- Data cleaning and merging


*******************************************************************************/



**# Combine baseline and midline survey to create master dataset ---------------
{
	
	* Load baseline survey 
	use "$TRICYCLE/data/baseline.dta", clear
	
	
	* Merge midline survey
	merge 1:1 id using "$TRICYCLE/data/midline.dta", keep(master match) 
	keep if _merge == 3
	drop _merge
	
	
	* Save as a master dataset
	save "$TRICYCLE/processed/master.dta", replace
	
}

**# Construct outcome variables ------------------------------------------------
{
	
	
	* Load the master dataset
	use "$TRICYCLE/processed/master", clear
	
	* Covid testing
	gen test = H1
	

	* Vaccination
	gen vaccine = H6


	* Misinformation
	local questions 			"H21 H22 H23 H24 H25 H26 H27 H28 H29 H30 H31"

	local right_answers 	"2 2 1 2 1 2 1 2 2 1 2"
	local wrong_answers		"1 1 2 1 2 1 2 1 1 2 1"
	
	foreach i of numlist 1/11{
		
		local question: word `i' of `questions'
		local right: word `i' of `right_answers'
		local wrong: word `i' of `wrong_answers'
		
		gen nr_`question' 		= 1 - (`question' == `right')

	}

	egen misinfo_nr = rowtotal(nr_*)
	replace misinfo_nr = misinfo_nr / 11
	
	label variable misinfo_nr "Index for belief in misinformation"
	

	foreach label in "nr_" ""{
		
		label variable `label'H21 "Vaccine can change DNA"
		label variable `label'H22 "Vaccine is fake"
		label variable `label'H23 "Vaccine has side effects"
		label variable `label'H24 "Vaccine suppress immune system"
		label variable `label'H25 "Mask helps"
		label variable `label'H26 "Vaccine is not effective"
		label variable `label'H27 "Can still pass COVID after vaccine"
		label variable `label'H28 "Vaccine causes infertility"
		label variable `label'H29 "Vaccine contains magnet"
		label variable `label'H30 "Vaccine reduces death"
		label variable `label'H31 "Vaccine contains fetus"
		
	}

	
	
	* Preventive behavior
	local prevention 		"H32 H33 H34 H35"
	egen prevention = rowtotal(`prevention')
	replace prevention = prevention / 4
	
	label variable prevention "Index for preventive behavior"
	label variable H32 "Avoid social gathering"
	label variable H33 "Wear mask"
	label variable H34 "Wash hands often"
	label variable H35 "Sneeze into elbow"
	
	
	
	* Labor market variables
	gen work_ecq = L1
	gen work_gcq = L8
	gen work_recent = L15
	
	gen tricycle_ecq = (work_ecq == 1 & inlist(L2, 4, 12))
	gen tricycle_gcq = (work_gcq == 1 & inlist(L9, 4, 12))
	gen tricycle_recent = (work_recent == 1 & inlist(L16, 4, 12))
	
	gen second_ecq = (work_ecq == 1 & (L4 == 1 | L6 == 1))
	gen second_gcq = (work_gcq == 1 & (L11 == 1 | L13 == 1))
	gen second_recent = (work_recent == 1 & (L21 == 1 | L27 == 1))

	
	* Normalize scores
	foreach var of varlist score*{
		qui sum `var'
		local max = r(max)
		replace `var' = `var' / `max'
	}
	
	
	* Save as a processed dataset
	save "$TRICYCLE/processed/master", replace
	
}

**# Variable labels ------------------------------------------------------------
{
	
	
	* Variables from the baseline survey
	foreach dataset in baseline{
		
		* Load the dataset
		use "$TRICYCLE/data/`dataset'", clear
		
		label variable male 			"Male"
		label variable married 			"Married"
		label variable edu 				"Years of schooling"
		label variable income_ind		"Individual income"
		label variable income_hh		"Household income"
		
		label variable rprefer 			"Risk preference"
		label variable impatience23		"Impatience"
		label variable ccei_risk		"CCEI from risk domain"
		label variable ccei_time23		"CCEI from time domain"
		label variable present_bias		"Present bias"
		label variable future_bias		"Future bias"
		label variable score_raven 		"Raven's test score"
		label variable score_numeracy	"Numeracy score"
		label variable score_financial	"Financial literacy score"
		
		
		* Save as a processed dataset
		save "$TRICYCLE/processed/`dataset'", replace
		
	}
	
	
	
	
	* Master dataset
	use "$TRICYCLE/processed/master", clear
	
	label variable male 			"Male"
	label variable married 			"Married"
	label variable edu 				"Years of schooling"
	label variable income_ind		"Individual income"
	label variable income_hh		"Household income"
	
	label variable rprefer 			"Risk preference"
	label variable impatience23		"Impatience"
	label variable ccei_risk		"CCEI from risk domain"
	label variable ccei_time23		"CCEI from time domain"
	label variable present_bias		"Present bias"
	label variable future_bias		"Future bias"
	label variable score_raven 		"Raven's test score"
	label variable score_numeracy	"Numeracy score"
	label variable score_financial	"Financial literacy score"
		
	
	label variable test 			"Received COVID test $\geq$ 1"
	label variable vaccine 			"Received COVID vaccine $\geq$ 1"
	label variable work_ecq			"Worked during ECQ"
	label variable work_gcq			"Worked during GCQ I"
	label variable work_recent		"Worked during GCQ II"
	
	
	
	foreach period in ecq gcq{
		label variable second_`period'	"Had a second job during `=proper("`period'")'"
	}
	label variable second_ecq		"Had a second job during ECQ"
	label variable second_gcq		"Had a second job during GCQ I"
	label variable second_recent 	"Had a second job during GCQ II"
		// Here, second job includes jobs as an employee for a private business and self-employed works
	
	
	* Save as a processed dataset
	save "$TRICYCLE/processed/master", replace
	
}

