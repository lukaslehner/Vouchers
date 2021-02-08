# Code for *Reframing active labor market policy: Experimental evidence of training vouchers for unemployed*

The master file is **0_master.R**.
All output (treatment assignment, tables and figures) produced by these scripts is available in the *Data/* subfolder.

## 1. Randomization and treatment assignment - Wave 1

The master file first calls **1a_randomization_data_prep.R** to prepare the data of unemployed in the sample for treatment assignment in the first wave.

In **1b_stratified_randomization.R**, the strata are constructed using the interaction command, which produces groups with every possible combination of the levels of the specified variables. The package randomizr is then used for stratified random assignment of treatment among 4 groups. The command complete_ra from the same package is used to randomize those observations with missing variables.

Further, it runs a series of descriptive checks of the quality of the randomization (plot for the distribution of the number of observations per strata, pairwise z-tests between the 4 groups for various relevant covariates, Chi-squared test for differences in covariates between the 4 groups), which are also stored in the *Data/* subfolder.

This script exports *wave_1_Control.xlsx*, *wave_1_T1.xlsx*, *wave_1_T1.xlsx* and *wave_1_T1.xlsx* to the *Data/* subfolder, which are used by the public employment service to implement the respective treatment. 

