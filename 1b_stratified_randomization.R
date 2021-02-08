###### Stratified Randomization for treatment assignment
library(randomizr)
### 0. Settings  ---------------------------------
file_used = c("wave_1.csv")

### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_1 = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))

### Stratification
#variables have to be defined as factors for stratification
wave_1$educ_f<-as.factor(wave_1$education)
wave_1$agegr_f<-as.factor(wave_1$agegr)
wave_1$male_f<-as.factor(wave_1$male)
wave_1$region_f<-as.factor(wave_1$region)

#without NAs (see below)
wave_1_NA<-wave_1%>%filter(is.na(education)|is.na(nationality_AUT))
wave_1=wave_1%>%filter(!is.na(education)& !is.na(nationality_AUT))

wave_1$strata<-interaction(wave_1[,c("educ_f","agegr_f","male_f","region_f")])
summary(wave_1$strata)

#------------------------------------------
set.seed(31)
wave_1$group_nr<-block_ra(blocks=wave_1$strata, prob_each=c(rep(0.25,4)),num_arms=4)

#randomize NAs

wave_1_NA$group_nr<-complete_ra(N=12,prob_each=c(rep(0.25,4)),num_arms=4)
summary(wave_1_NA$group_nr)

wave_1_NA$strata<-NA
wave_1_NA$no_rows<-NA

wave_1<-bind_rows(wave_1,wave_1_NA)

#check
library(dplyr)
library(expss)
library(xtable)

#strata sizes plot
#no observations per strata
wave_1<-wave_1 %>% 
  group_by(strata) %>%
  mutate(no_rows = length(personal_id))%>%ungroup()


wave_1$strata = with(wave_1, reorder(strata, no_rows, median))
wave_1 %>%
  ggplot( aes(x=strata))+geom_bar()+labs(x="",y="observations",title = "Strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())

#z-test between column percents each compared with each
table11<-wave_1%>%tab_cells(educ_f,agegr_f,region_f,male_f,as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+as.factor(nationality_AUT)+as.factor(health_condition)+
                as.factor(marginal_employment)+as.factor(German_ok), data=wave_1)

capture.output(summary(tab1), file="Test.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test.md", pdf_document(keep_tex=TRUE))

# exporting files for AMS; one for each wave
library("writexl")


write_xlsx(wave_1,paste(data_path,"wave_1_assignment.xlsx", sep="/"))

T1<-wave_1%>%ungroup()%>%filter(group_nr=="T1")%>%select(personal_id)
T2<-wave_1%>%ungroup()%>%filter(group_nr=="T2")%>%select(personal_id)
T3<-wave_1%>%ungroup()%>%filter(group_nr=="T3")%>%select(personal_id)
T4<-wave_1%>%ungroup()%>%filter(group_nr=="T4")%>%select(personal_id)

write_xlsx(T1,paste(data_path,"wave_1_Control.xlsx", sep="/"))
write_xlsx(T2,paste(data_path,"wave_1_T1.xlsx", sep="/"))
write_xlsx(T3,paste(data_path,"wave_1_T2.xlsx", sep="/"))
write_xlsx(T4,paste(data_path,"wave_1_T3.xlsx", sep="/"))
