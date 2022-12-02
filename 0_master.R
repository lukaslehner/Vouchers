library(tidyverse)
library(lubridate)

setwd("..")
home <- getwd()
data_out <- paste0(home, "/Data")
setwd("./Vouchers")

### 1. Experiment ----------
# 1- Wave 1 Stratified randomization  -------- 

data_path = "A:/"

# Data preparation for randomization
source("1a_randomization_data_prep.R")

# Constructing the treatment assignment
source("1b_stratified_randomization.R")

# Tables and plots for evaluating the stratified randomization of treatment

#2- Wave 2 stratified randomization ---------

# Data preparation for randomization
source("2a_randomization_data_prep.R")

# Constructing the treatment assignment
source("2b_stratified_randomization.R")

#3- Wave 3 stratified randomization ---------

# Data preparation for randomization
source("3a_randomization_data_prep.R")

# Constructing the treatment assignment
source("3b_stratified_randomization.R")

#4-merge intervention 1--------------
source("4_merge.R")
#full_data_1 sums all waves from first intervention

#5- Wave 4 stratified randomization w/o mail GF2Q-GF4Q---------

# Data preparation for randomization
source("5a_randomization_data_prep.R")

# Constructing the treatment assignment
source("5b_stratified_randomization.R")

### 2. Experiment ----------
#6- stratified randomization GF1J---------

# Data preparation for randomization
source("6a_randomization_data_prep.R")

# Constructing the treatment assignment
source("6b_stratified_randomization.R")

#7- merge wave 4 and 2. experiment---------

source("7_merge.R")
#full_data_2 sums both groups from intervention 2

