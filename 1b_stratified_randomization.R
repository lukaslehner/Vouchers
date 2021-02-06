###### Stratified Randomization for treatment assignment
library(randomizr)
### 0. Settings  ---------------------------------
file_used = c("wave_1.csv")


### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_1 = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))


### Stratification
#what about NAs?
wave_1=wave_1%>%filter(!is.na(education)& !is.na(nationality_AUT))
#variables have to be defined as factors for stratification
wave_1$educ_f<-as.factor(wave_1$education)
wave_1$agegr_f<-as.factor(wave_1$agegr)
wave_1$male_f<-as.factor(wave_1$male)
wave_1$nationality_AUT_f<-as.factor(wave_1$nationality_AUT)
wave_1$health_condition_f<-as.factor(wave_1$health_condition)
wave_1$marginal_employment_f<-as.factor(wave_1$marginal_employment)
wave_1$German_ok_f<-as.factor(wave_1$German_ok)

wave_1$strata<-interaction(wave_1[,c("educ_f","agegr_f","male_f","nationality_AUT_f","health_condition_f","marginal_employment_f","German_ok_f")])
#mit German_ok noch immer sehr viele Strata, ohne weniger(aber manche sehr klein)__> Lösung? 


#------------------------------------------
wave_1$group_nr<-block_ra(blocks=wave_1$strata, prob_each=c(rep(0.25,4)),num_arms=4)

#check
library(dplyr)
library(expss)

wave_1%>%tab_cells(educ_f,agegr_f,male_f,nationality_AUT_f,health_condition_f,marginal_employment_f,German_ok_f)%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")


# exporting files for AMS; one for each wave
nr = (1:4)

for (group_nr in nr) {
participant_assignment_full %>%
  filter(group == group_nr) %>%
  select(personal_id) %>%
  write_csv(paste0(data_out, "Gruppe_$group_nr.csv"))
}

