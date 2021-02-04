###### Data preparation for matching
library(xlsx)
library(dplyr)

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

#import isco and recode
library(readxl)
file_used=c("isco-help.xlsx")
isco<-paste(data_path, file_used, sep = "") %>% 
  read_excel( ,col_types = c("numeric", "numeric", "text") )

isco$letzter.Beruf.6.ST<-isco$BERUF_6
isco$BERUF_6<-NULL

data<-left_join(wave_1_raw,isco,by=c("letzter.Beruf.6.ST"),copy=TRUE)
data$personal_id = as.integer(data$PST_Nummer)
data<-data%>%select(personal_id,letzter.Beruf.6.ST,ISCO08_1,ISCO08_1_BEZ)

wave_1<-left_join(wave_1,data,by=c("personal_id"))

#ein paar sind noch nicht zugeordnet(32), keine info in tabelle (könnte aber schon noch zugeordnet werden, wenn wirs doch noch brauchen, bisschen mühsam)
rm(data,isco)
#

wave_1 %>% 
  readr::write_csv(paste(data_path,
                  "wave_1.csv",
                  sep = ""))
