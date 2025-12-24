# Misinformation Belief, Health Behavior, and Labor Supply during the COVID-19 Pandemic: Evidence from Tricycle Drivers in Philippines

-----------

## Overview

This repository contains data and code for the paper:

Misinformation Belief, Health Behavior, and Labor Supply during the COVID-19 Pandemic: Evidence from Tricycle Drivers in Philippines

Authors: Siho Park, Syngjoo Choi, Hyuncheol Bryant Kim, Yasuyuki Sawada, and Takashi Yamano


## Software requirements
Stata version 18 is used
  - Add-on packages are included in **scripts/libraries** and do not need to be installed by user. The names, installation sources, and installation dates of these packages are available in **scripts/libraries/stata.trk**.


## Instructions
Executing the master script **run.do** will run the entire analysis and generate all tables and figures. Before running this script, you must make one edit:
  1. Line 31: Define a global macro, **TRICYCLE**, that points to the directory containing this README file
For example, that line should look something like the following:
```stata
global TRICYCLE "C:/Users/jdoe/my-project/analysis"
```

## Directory structure
```text
my-project/analysis/		    # Replication package folder
├── data			              # Read-only (input) data
├── processed			          # Processed data
├── results			            # Output files
│   ├── tables			        # Tables (LaTeX)
│   ├── figures			        # Figures (png)
├── scripts
│   ├── libraries		        # Add-on Stata packages
│   ├── 0_programs.do		    # Auxiliary code called by scripts
│   ├── 1_clean_data.do
│   ├── 2_make_figures.do
│   ├── 3_make_tables.do
└── run.do			            # Master script
```

## Dataset
1. baseline.dta: This dataset include first survey responses.
2. midline.dta: This dataset include second survey responses.


## Description of scripts
**run.do** is a master script that sets up the environment, creates output folders, and then calls other scripts.

**0_programs.do**
This scripts runs author-written codes for storing analysis results.

**1_clean_data.do**
This script cleans the input data and creates the processed data ready for analysis.

**2_make_figures.do**
This script creates figures, saving them to **results/figures**.

**3_make_tables.do**
This script creates tables, saving them to **results/tables**.



