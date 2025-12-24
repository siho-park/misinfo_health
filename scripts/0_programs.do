

* Create frame for storing results --------------------------------------------

	capture frame create result
	frame change default

	

* Programs ---------------------------------------------------------------------
{
program drop _all



* Programs for making table

program set_obs, nclass
	syntax, line(int)

	* Turn to result frame
	frame change result
	
	
	* Set observation number
	set obs `line'
	
	
	* Return to default frame
	frame change default

end

program set_col, nclass
	syntax, name(string)
	
	* Turn to result frame
	frame change result
	
	
	* Create columns
	foreach var in `name'{
		gen `var' = ""
	}
	
	
	* Return to default frame
	frame change default
	
end

program write_beta, nclass
	syntax, outcome(string) ind(string) line(int) df(int) [format(string)]

	
	
	* Default format for numerical output
	local smaller = min(abs(_b[`ind']), abs(_se[`ind']))
	
	if !missing("`format'"){
		di "Use the given format"
	}
	else if `smaller' < 0.000001{
		local format "%12.7f"
	}
	else if `smaller' < 0.00001{
		local format "%12.6f"
	}
	else if `smaller' < 0.0001{
		local format "%12.5f"
	}
	else if `smaller' < 0.001{
		local format "%12.4f"
	}
	else{
		local format "%12.3f"
	}
	
	
	* Turn to default frame
	frame change default
	
	
	* Store the point estimate and the standard error
	local point 	= string(_b[`ind'], "`format'")
	local se		= "(" + string(_se[`ind'], "`format'") + ")"
	
	
	* Add statistical significance
	if `df' > 0{
		local pval = (2 * ttail(`df', abs(_b[`ind']/_se[`ind'])))
	}
	if `df' == 0{
		local pval = (2 * (1 - normal(abs(_b[`ind']/_se[`ind']))))
	}
	
	
	if `pval' < 0.01 {
		local point = "`point'" + "***"
	}
	else if `pval' < 0.05 {
		local point = "`point'" + "**"
	}
	else if `pval' < 0.1 {
		local point = "`point'" + "*"
	}

	
	* Turn to result frame
	frame change result
	
	
	
	* Write the estimation result in the given line
	replace `outcome' = "`point'" in `line'
	replace `outcome' = "`se'" in `=`line'+1'
		// Note that the line position is for point estimate, not the standard error

	
	
	* Return to default frame
	frame change default
	
	
end

program write_name, nclass
	syntax, name(string) line(int)
	
	
	* Turn to result frame
	frame change result
	
	
	* Get the first variable
	qui ds
	local first: word 1 of `r(varlist)'
	
	
	* Add the string
	replace `first' = "`name'" in `line'
	
	
	* Return to default frame
	frame change default
	
end

program write_est, nclass
	syntax, outcome(string) name(string) line(int) 
	
	
	* Turn to result frame
	frame change result
	
	
	* Write the estimation result
	replace `outcome' = "`name'" in `line'
	
	
	* Return to default frame
	frame change default
	

end

program write_lincom, nclass
	syntax, outcome(string) line(int) [format(string)]
	
	
	* Default format for numerical output
	if missing("`format'") local format %12.3f
	
	
	* Write estimates of average distance
	local point 	= string(`r(estimate)', "`format'")
	local se 		= "(" + string(`r(se)', "`format'") + ")"
	
	if `r(p)' < 0.01 {
		local point = "`point'" + "***"
	}
	else if `r(p)' < 0.05 {
		local point = "`point'" + "**"
	}
	else if `r(p)' < 0.1 {
		local point = "`point'" + "*"
	}
	
	write_est, outcome(`outcome') name("`point'") line(`line')
	write_est, outcome(`outcome') name("`se'") line(`=`line' + 1')



end

program write_bootstrap, nclass
	syntax, outcome(string) line(int) ratio(int) [format(string)]

	* Output bootstrap results
	matrix A = r(table)
	
	
	* Format coefficient, standard error, and confidence interval
	local point	= string(A[1, 1], "`format'")
	local se 	= "(" + string(A[2, 1], "`format'") + ")"
	
	
	
	* If ratio, hypothesis testing: beta = 1
	if `ratio' == 0{
		local pval = A[4, 1]
	}
	else if `ratio' == 1{
		local z = (A[1, 1] - 1) / A[2, 1]
		local pval = 2 * (1 - normal(abs(`z')))
	}
	
	
	
	* Add significance level asterisk
	if `pval' < 0.01 {
		local point = "`point'" + "***"
	}
	else if `pval' < 0.05 {
		local point = "`point'" + "**"
	}
	else if `pval' < 0.1 {
		local point = "`point'" + "*"
	}
	
	
	* Write the output in the result frame
	write_est, name("`point'") outcome(`outcome') line(`line')
	write_est, name("`se'") outcome(`outcome') line(`=`line' + 1')
	
	
	* Add confidence interval if ratio = 1
	if `ratio' == 1{
		local ub 	= A[6, 1]
		local lb	= A[5, 1]
		cap write_est, name("`ub'") outcome(`outcome'_ub) line(`line')
		cap write_est, name("`lb'") outcome(`outcome'_lb) line(`line')
	}
	
	* Return to default frame
	frame change default
	

end


}
