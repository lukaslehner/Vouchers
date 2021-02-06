library(tidyverse)
library(lubridate)

home <- getwd()
data_out <- paste0(home, "/Data/")

# 1. Stratified randomization  -------- 

# data path for local data: switch between Anna and Lukas
  data_path = "V:/" # Lukas
# data_path = " " # Anna

# Data preparation for randomization
source("1a_randomization_data_prep.R")

# Constructing the treatment assignment
source("1b_stratified_randomization.R")

# Tables and plots for evaluating the stratified randomization of treatment


