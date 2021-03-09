###### Stratified Randomization for treatment assignment
library(randomizr)
library(readr)

### 0. Settings  ---------------------------------
file_used = c("wave_123_wo.csv")

### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
wave_123_wo = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))

#remove those whoe are already treated
wave_123_wo<-wave_123_wo%>%filter(overlap==0)
wave_123_wo$overlap<-NULL

### Stratification
#variables have to be defined as factors for stratification
wave_123_wo$educ_f<-as.factor(wave_123_wo$education)
wave_123_wo$agegr_f<-as.factor(wave_123_wo$agegr)
wave_123_wo$male_f<-as.factor(wave_123_wo$male)
wave_123_wo$region_f<-as.factor(wave_123_wo$region)

#without NAs (see below)
wave_123_wo_NA<-wave_123_wo%>%filter(is.na(education))
wave_123_wo=wave_123_wo%>%filter(!is.na(education))

wave_123_wo$strata<-interaction(wave_123_wo[,c("educ_f","agegr_f","male_f","region_f")])
summary(wave_123_wo$strata)

#------------------------------------------
set.seed(3006)
wave_123_wo$group_nr<-block_ra(blocks=wave_123_wo$strata, prob_each=c(rep(0.25,4)),num_arms=4)

#randomize NAs

wave_123_wo_NA$group_nr<-complete_ra(N=13,prob_each=c(rep(0.25,4)),num_arms=4)
summary(wave_123_wo_NA$group_nr)

wave_123_wo_NA$strata<-NA
wave_123_wo_NA$no_rows<-NA

wave_123_wo<-bind_rows(wave_123_wo,wave_123_wo_NA)

#check
library(dplyr)
library(expss)
library(xtable)

library(ggplot2)

#strata sizes plot
#no observations per strata
wave_123_wo<-wave_123_wo %>% 
  group_by(strata) %>%
  mutate(no_rows = length(personal_id))%>%ungroup()


wave_123_wo$strata = with(wave_123_wo, reorder(strata, no_rows, median))
wave_123_wo %>% filter(!is.na(strata))%>%
  ggplot( aes(x=strata))+geom_bar()+labs(x="",y="observations",title = "Strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())
ggsave("strataplot_123_wo.png", path=data_out)

#z-test between column percents each compared with each
table11<-wave_123_wo%>%tab_cells(educ_f,agegr_f,region_f,male_f, unemp_dur,as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+unemp_dur+as.factor(nationality_AUT)+as.factor(health_condition)+
                as.factor(marginal_employment)+as.factor(German_ok), data=wave_123_wo)
summary(tab1, text=TRUE)
setwd(data_out)
capture.output(summary(tab1), file="Test_w123_wo.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test_w123_wo.md", pdf_document(keep_tex=TRUE))

# exporting files for AMS; one for each wave
library("writexl")

T1<-wave_123_wo%>%ungroup()%>%filter(group_nr=="T1")%>%select(personal_id)
T2<-wave_123_wo%>%ungroup()%>%filter(group_nr=="T2")%>%select(personal_id)
T3<-wave_123_wo%>%ungroup()%>%filter(group_nr=="T3")%>%select(personal_id)
T4<-wave_123_wo%>%ungroup()%>%filter(group_nr=="T4")%>%select(personal_id)

write_xlsx(T1,paste(data_out,"wave_123_wo_Control.xlsx", sep="/"))
write_xlsx(T2,paste(data_out,"wave_123_wo_T1.xlsx", sep="/"))
write_xlsx(T3,paste(data_out,"wave_123_wo_T2.xlsx", sep="/"))
write_xlsx(T4,paste(data_out,"wave_123_wo_T3.xlsx", sep="/"))

write_xlsx(wave_123_wo, paste(data_path,"wave_123_wo_assigned.xlsx",sep="/"))
