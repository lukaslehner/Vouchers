###### Data preparation for matching
library(xlsx)

### 0. Settings  ---------------------------------
file_used = c("1-Wave.xlsx")


### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_1_raw = paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

# aggregate variables for stratified randomisation
wave_1 =
  wave_1_raw  %>%
  mutate(
    personal_id = as.integer(PST_Nummer),
    counselor_id = as.integer(APL.anonym),
    nationality_AUT = as.integer(Nation == "A"),
    male = as.integer(Geschlecht == "M"),
    marginal_employment = as.integer(GER != "-"),
    education = as.integer((höchste.Ausbildung != "PS") & (höchste.Ausbildung != "PO")), # higher than Pflichtschule
    age = Alter , 
    health_condition = as.integer(Beguenstigung != "-"), # employment relevant health condition
    education = as.integer((Deutschkenntnisse != "PS") & (Deutschkenntnisse != "PO")), # more than Pflichtschule
    German_ok = as.integer((Deutschkenntnisse != "K") & (Deutschkenntnisse != "A")
                         & (Deutschkenntnisse != "A1") & (Deutschkenntnisse != "A2")
                         & (Deutschkenntnisse != "B1") & (Deutschkenntnisse != "B2")
                         & (Deutschkenntnisse != "B")) # more than B
    ) %>%
  select(personal_id, 
         counselor_id, 
         nationality_AUT, 
         male, 
         marginal_employment, 
         education, 
         age, 
         health_condition,
         education, 
         German_ok)


wave_1 %>% 
  write_csv(paste(data_path,
                  "wave_1.csv",
                  sep = ""))
