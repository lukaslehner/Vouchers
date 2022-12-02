# Code for the experimental design of *Reframing active labor market policy: Experimental evidence of training vouchers for unemployed*

This readme gives an overview of the replication files for the experimental design of our study, in particular the **treatment assignment**.

## Structure of code

The entire study design can be replicated from the raw data by running **0_master.R**.

All output (treatment assignment, tables and figures) produced by these scripts is available in the *Data/* subfolder.

The scripts for experiment 1 are organized into 4 waves of treatment (scripts starting with 1 to 5). All data are merged after wave 3, and after complete assignment for both experiments. The code for treatment assignment for experiment 2 are in the scripts starting with 6. Script 7 merges the assigned data of both experiments.

### 1. Experiment

1. Wave
    1. Data preparation: *1a_randomization_data_prep.R*
    2. Treatment assignment: *1b_stratified_randomization.R*

2. Wave
    1. Data preparation: *2a_randomization_data_prep.R*
    2. Treatment assignment: *2b_stratified_randomization.R*

3. Wave
    1. Data preparation: *3a_randomization_data_prep.R*
    2. Treatment assignment: *3b_stratified_randomization.R*

- *4_merge.R* merges the data after completion of 3 email waves for experiment 1.

4. Wave: assignment for unemployed without email to receive a postal letter instead of email.
    1. Data preparation: *5a_randomization_data_prep.R*
    2. Treatment assignment: *5b_stratified_randomization.R*

### 2. Experiment

    1. Data preparation: *6a_randomization_data_prep.R*
    2. Treatment assignment: *6b_stratified_randomization.R*

- *7_merge.R* merges the data.

## Content of the code

The scripts are organized into waves of treatment. For each wave, the master file first calls the respective script to prepare the data, such as **1a_randomization_data_prep.R** to prepare the data for wave one. The data contains unemployed in the sample for treatment assignment.

Subsequently, the master file calls the script to assign treatment through stratified randomization, such as **1b_stratified_randomization.R** for wave one. The strata are constructed using the interaction command, which produces groups with every possible combination of the levels of the specified variables. The package *randomizr* is then used for stratified random assignment of treatment among 4 groups. The command *complete_ra* from the same package is used to randomize those observations with missing variables.

Further, the script runs a series of descriptive checks of the quality of the randomization. This includes a plot for the distribution of the number of observations per strata, pairwise z-tests between the 4 groups for various relevant covariates, and a Chi-squared test for differences in covariates between the 4 groups, which are stored in the *Data/* subfolder.

Finally, the script exports a separate spreadsheet file for each group to which individuals are assigned to, such as for wave one *wave_1_Control.xlsx*, *wave_1_T1.xlsx*, *wave_1_T2.xlsx* and *wave_1_T3.xlsx* to the *Data/* subfolder. These files are used by the public employment service to implement the respective treatment. 

## Pre-registration and code
The experiment is pre-registered at the AEA RCT registry, [https://www.socialscienceregistry.org/trials/7141](https://www.socialscienceregistry.org/trials/7141). The code for the experiment design is publicly available at [https://github.com/lukaslehner/Vouchers](https://github.com/lukaslehner/Vouchers).