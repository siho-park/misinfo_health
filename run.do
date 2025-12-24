/*********************************************************************************************************

* Overview
- Author: Siho Park, Syngjoo Choi, Hyuncheol Bryant Kim, Yasuyuki Sawada, Takashi Yamano
- Creation date: October 4, 2021
- Title: Misinformation Belief, Health Behavior, and Labor Supply 
	during the COVID-19 Pandemic: Evidence from Tricycle Drivers in the Philippines

	
* Output
- All raw data are stored in data
- All tables are produced as output to results/tables
- All figures are produced as output to results/figures

* Replication
- To perform a clean run, delete the following two folders and run the whole codes: 
	/processed, /results

* System requirement
- Analysis initially run on Windows using Stata 18

*************************************************************************************************************/

* Code environment
set more off, permanently
set varabbrev on
graph set window fontface "Times New Roman"

* My projects
* User must set the global macro TRICYCLE to the path of the folder that includes master.do
global TRICYCLE "$DROPBOX/Econ research projects/Misinformation and vaccination/replication"


* Confirm that the global for the project root directory has been defined
assert !missing("$TRICYCLE")


* Initialize log and record system parameters
clear
capture mkdir "$TRICYCLE/processed"
capture mkdir "$TRICYCLE/results"
capture mkdir "$TRICYCLE/results/tables"
capture mkdir "$TRICYCLE/results/figures"
capture mkdir "$TRICYCLE/scripts/logs"

capture log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$TRICYCLE/scripts/logs/`datetime'.log.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"


* All required Stata packages are available in the /libraries/stata folder
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
  if `"`1'"'!="BASE" cap adopath - `"`1'"'
  macro shift
}
adopath ++ "$TRICYCLE/scripts/libraries"
mata: mata mlib index


* Stata version control
version 17


* Run all do files
do "$TRICYCLE/scripts/0_programs.do"
do "$TRICYCLE/scripts/1_clean_data.do"
do "$TRICYCLE/scripts/2_make_figures.do"
do "$TRICYCLE/scripts/3_make_tables.do"


* End log
di "End date and time: $S_DATE $S_TIME"
log close

* End of file

