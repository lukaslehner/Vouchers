###### Stratified Randomization for treatment assignment
library(randomizr)
library(readr)

### 0. Settings  ---------------------------------
file_used = c("wave_3.csv")

### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_3 = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))

### Stratification
#variables have to be defined as factors for stratification
wave_3$educ_f<-as.factor(wave_3$education)
wave_3$agegr_f<-as.factor(wave_3$agegr)
wave_3$male_f<-as.factor(wave_3$male)
wave_3$region_f<-as.factor(wave_3$region)

#without NAs (see below)
wave_3_NA<-wave_3%>%filter(is.na(education)|is.na(nationality_AUT))
wave_3=wave_3%>%filter(!is.na(education)& !is.na(nationality_AUT))

wave_3$strata<-interaction(wave_3[,c("educ_f","agegr_f","male_f","region_f")])
summary(wave_3$strata)

#------------------------------------------
set.seed(851)
wave_3$group_nr<-block_ra(blocks=wave_3$strata, prob_each=c(rep(0.25,4)),num_arms=4)

#randomize NAs

wave_3_NA$group_nr<-complete_ra(N=11,prob_each=c(rep(0.25,4)),num_arms=4)
summary(wave_3_NA$group_nr)

wave_3_NA$strata<-NA
wave_3_NA$no_rows<-NA

wave_3<-bind_rows(wave_3,wave_3_NA)

#check
library(dplyr)
library(expss)
library(xtable)

library(ggplot2)

#strata sizes plot
#no observations per strata
wave_3<-wave_3 %>% 
  group_by(strata) %>%
  mutate(no_rows = length(personal_id))%>%ungroup()


wave_3$strata = with(wave_3, reorder(strata, no_rows, median))
wave_3 %>% filter(!is.na(strata))%>%
  ggplot( aes(x=strata))+geom_bar()+labs(x="",y="observations",title = "Strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())
ggsave("strataplot_3.png", path=data_out)

#z-test between column percents each compared with each
table11<-wave_3%>%tab_cells(educ_f,agegr_f,region_f,male_f,as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+as.factor(nationality_AUT)+as.factor(health_condition)+
                as.factor(marginal_employment)+as.factor(German_ok), data=wave_3)
summary(tab1, text=TRUE)
setwd(data_out)
capture.output(summary(tab1), file="Test_w3.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test_w3.md", pdf_document(keep_tex=TRUE))

# exporting files for AMS; one for each wave
library("writexl")

T1<-wave_3%>%ungroup()%>%filter(group_nr=="T1")%>%select(personal_id)
T2<-wave_3%>%ungroup()%>%filter(group_nr=="T2")%>%select(personal_id)
T3<-wave_3%>%ungroup()%>%filter(group_nr=="T3")%>%select(personal_id)
T4<-wave_3%>%ungroup()%>%filter(group_nr=="T4")%>%select(personal_id)

write_xlsx(T1,paste(data_out,"wave_3_Control.xlsx", sep="/"))
write_xlsx(T2,paste(data_out,"wave_3_T1.xlsx", sep="/"))
write_xlsx(T3,paste(data_out,"wave_3_T2.xlsx", sep="/"))
write_xlsx(T4,paste(data_out,"wave_3_T3.xlsx", sep="/"))

write_xlsx(wave_3, paste(data_path,"wave_3_assigned.xlsx",sep="/"))
