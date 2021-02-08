###### Data preparation for matching
library(xlsx)
library(dplyr)

### 0. Settings  ---------------------------------
file_used = c("1-Wave.xlsx")

 ### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_1_raw = paste(data_path, file_used, sep = "/") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

# aggregate variables for stratified randomisation
wave_1 =
  wave_1_raw  %>%
  mutate(
    personal_id = as.integer(PST_Nummer),
    counselor_id = as.integer(APL.anonym),
    rgs_id = as.integer(GS.PST),
    region=case_when(GS.PST==301 | GS.PST==317|GS.PST==326|GS.PST==328|GS.PST==3310|GS.PST==333~"Mo",
                     GS.PST==311 | GS.PST==313|GS.PST==315|GS.PST==332|GS.PST==335~"Wa",
                     GS.PST==3080 | GS.PST==312|GS.PST==314|GS.PST==319~"We",
                     GS.PST==304 | GS.PST==306|GS.PST==321|GS.PST==323|GS.PST==329|GS.PST==334~"In"),
    nationality_AUT = as.integer(Nation == "A"),
    male = as.integer(Geschlecht == "M"),
    agegr= case_when(Alter<35~"y",
                     Alter>34 & Alter<50 ~ "m",
                     Alter>49 ~ "o"),
    marginal_employment = as.integer(!is.na(GER)),
    education = as.integer((höchste.Ausbildung != "PS") & (höchste.Ausbildung != "PO")), # higher than Pflichtschule
    age = Alter , 
    medical_condition = as.integer(Beguenstigung != "-"), # employment relevant health condition
    health_condition = as.integer(Beguenstigung != "-"), # employment relevant health condition
    German_ok = as.integer((Deutschkenntnisse != "K") & (Deutschkenntnisse != "A")
                         & (Deutschkenntnisse != "A1") & (Deutschkenntnisse != "A2")
                         & (Deutschkenntnisse != "B1") & (Deutschkenntnisse != "B2")
                         & (Deutschkenntnisse != "B")) # more than B
    )

#Korrekturen
wave_1$education[wave_1$höchste.Ausbildung=="XX"]<-NA 
wave_1$German_ok[is.na(wave_1$Deutschkenntnisse)]<-1
wave_1$nationality_AUT[wave_1$Nation=="X"]<-NA 

wave_1=wave_1%>%select(personal_id,
                counselor_id,
                rgs_id,
                nationality_AUT, 
                male,
                agegr,
                region,
                marginal_employment, 
                education, 
                age, 
                health_condition,
                education, 
                German_ok)

#import isco and recode
library(readxl)
file_used=c("isco-help.xlsx")
isco<-paste(data_path, file_used, sep = "/") %>% 
  read_excel( ,col_types = c("numeric", "numeric", "text") )

isco$letzter.Beruf.6.ST<-isco$BERUF_6
isco$BERUF_6<-NULL

data<-left_join(wave_1_raw,isco,by=c("letzter.Beruf.6.ST"),copy=TRUE)
data$personal_id = as.integer(data$PST_Nummer)
data<-data%>%select(personal_id,letzter.Beruf.6.ST,ISCO08_1,ISCO08_1_BEZ)

wave_1<-left_join(wave_1,data,by=c("personal_id"))
summary(wave_1$ISCO08_1)
#ein paar sind noch nicht zugeordnet(32), keine info in tabelle (könnte aber schon noch zugeordnet werden, wenn wirs doch noch brauchen, bisschen mühsam)
rm(data,isco)
#

wave_1 %>% 
  readr::write_csv(paste(data_path,
                  "wave_1.csv",
                  sep = ""))
