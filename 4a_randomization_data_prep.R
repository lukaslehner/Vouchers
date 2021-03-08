###### Data preparation for matching
library(xlsx)
library(dplyr)

### 0. Settings  ---------------------------------
file_used = c("1-3-Wave_oMail.xlsx")

 ### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_123_wo_raw = paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

# aggregate variables for stratified randomisation
wave_123_wo =
  wave_123_wo_raw  %>%
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
wave_123_wo$education[wave_123_wo$höchste.Ausbildung=="XX"]<-NA 
wave_123_wo$German_ok[is.na(wave_123_wo$Deutschkenntnisse)]<-1
wave_123_wo$nationality_AUT[wave_123_wo$Nation=="X"]<-NA 

wave_123_wo<-wave_123_wo%>%mutate(unemp_dur=case_when(
  GF=="2_GF2Q"~"2Q",
  GF=="3_GF3Q"~"3Q",
  GF=="4_GF4Q"~"4Q"
))
wave_123_wo$unemp_dur<-as.factor(wave_123_wo$unemp_dur)

wave_123_wo=wave_123_wo%>%select(personal_id,
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
                German_ok,
                letzter.Beruf.6.ST,
                unemp_dur)

#check overlap with previous sample
file_used = c("full_data.xlsx")

### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
full_data = paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

overlap<-semi_join(wave_123_wo, full_data, by="personal_id")
overlap$overlap<-1
overlap<-overlap%>%select(personal_id, overlap)

wave_123_wo<-left_join(wave_123_wo,overlap,by=c("personal_id"))
wave_123_wo$overlap[is.na(wave_123_wo$overlap)]<-0
summary(as.factor(wave_123_wo$overlap))

rm(overlap)

#import isco and recode
library(readxl)
file_used=c("isco-help.xlsx")
isco<-paste(data_path, file_used, sep = "/") %>% 
  read_excel( ,col_types = c("numeric", "numeric", "text") )

isco$letzter.Beruf.6.ST<-isco$BERUF_6
isco$BERUF_6<-NULL

data<-left_join(wave_123_wo_raw,isco,by=c("letzter.Beruf.6.ST"),copy=TRUE)
data$personal_id = as.integer(data$PST_Nummer)
data<-data%>%select(personal_id,letzter.Beruf.6.ST,ISCO08_1,ISCO08_1_BEZ)

wave_123_wo<-left_join(wave_123_wo,data,by=c("personal_id"))
summary(wave_123_wo$ISCO08_1)
#ein paar sind noch nicht zugeordnet(32), keine info in tabelle (könnte aber schon noch zugeordnet werden, wenn wirs doch noch brauchen, bisschen mühsam)
rm(data,isco)
#

wave_123_wo %>% 
  readr::write_csv(paste(data_path,
                  "wave_123_wo.csv",
                  sep = ""))
