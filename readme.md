# Code for *Reframing active labor market policy: Experimental evidence of training vouchers for unemployed*

The master file is **0_master.R**.
All output (treatment assignment, tables and figures) produced by these scripts is available in the *Data/* subfolder.

## 1. Randomization and treatment assignment - Wave 1

The master file first calls **1a_randomization_data_prep.R** to prepare the data of unemployed in the sample for treatment assignment.

In **1b_stratified_randomization.R**, the package * * is then used for stratified random assignment of treatment among 4 groups.
This script exports *wave_1_Control.xlsx*, *wave_1_T1.xlsx*, *wave_1_T1.xlsx* and *wave_1_T1.xlsx* to the *Data/* subfolder, which are used by the public employment service to implement the respective treatment. Further, it runs a series of descriptive checks of the quality of the randomization, which are also stored in the *Data/* subfolder.

