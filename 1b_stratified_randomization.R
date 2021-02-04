###### Stratified Randomization for treatment assignment

### 0. Settings  ---------------------------------
file_used = c("wave_1.csv")


### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_1 = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))


### Stratification Variables






# exporting files for AMS; one for each wave
nr = (1:4)

for (group_nr in nr) {
participant_assignment_full %>%
  filter(group == group_nr) %>%
  select(personal_id) %>%
  write_csv(paste0(data_out, "Gruppe_$group_nr.csv"))
}

