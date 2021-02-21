library(tidyverse)
library(lubridate)

setwd("..")
home <- getwd()
data_out <- paste0(home, "/Data")
setwd("./Vouchers")

# 1. Wave 1 Stratified randomization  -------- 

# data path for local data: switch between Anna and Lukas
#  data_path = "V:/" # Lukas
 data_path = "A:/" # Anna

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

