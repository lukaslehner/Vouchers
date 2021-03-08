###### Stratified Randomization for treatment assignment
library(randomizr)
library(readr)

### 0. Settings  ---------------------------------
file_used = c("ausw.csv")

### 1. Main covariate file and merge ---------------------------------

# reading in participant file from source data
ausw = paste(data_path, file_used, sep = "") %>% 
  read_delim(delim = ",", locale = locale(encoding = "latin1", decimal_mark = ","))

### Stratification
#variables have to be defined as factors for stratification
ausw$educ_f<-as.factor(ausw$education)
ausw$agegr_f<-as.factor(ausw$agegr)
ausw$male_f<-as.factor(ausw$male)
ausw$region_f<-as.factor(ausw$region)
ausw$mail_f<-as.factor(ausw$mail)

#without NAs (see below)
ausw_NA<-ausw%>%filter(is.na(education))
ausw=ausw%>%filter(!is.na(education))

ausw$strata<-interaction(ausw[,c("educ_f","agegr_f","male_f","region_f", "mail_f")])
summary(ausw$strata)

#allocate too small strata to complete randomization dataset (smaller than 7)
small<-ausw%>%filter(strata=="1.y.0.Mo.0"|strata=="1.y.0.Wa.0"|
                       strata=="1.y.1.Wa.0"|strata=="1.y.0.We.0")

ausw_NA<-bind_rows(ausw_NA,small)
rm(small)

ausw<-ausw%>%filter(strata!="1.y.0.Mo.0"&strata!="1.y.0.Wa.0"&
                      strata!="1.y.1.Wa.0"&strata!="1.y.0.We.0")

ausw$strata<-droplevels(ausw$strata)

#------------------------------------------
set.seed(842)
ausw$group_nr<-block_ra(blocks=ausw$strata, prob_each=c(rep(0.25,4)),num_arms=4)

#randomize NAs

ausw_NA$group_nr<-complete_ra(N=41,prob_each=c(rep(0.25,4)),num_arms=4)
summary(ausw_NA$group_nr)

ausw_NA$strata<-NA
ausw_NA$no_rows<-NA

ausw<-bind_rows(ausw,ausw_NA)

#check
library(dplyr)
library(expss)
library(xtable)

library(ggplot2)

#strata sizes plot
#no observations per strata
ausw<-ausw %>% 
  group_by(strata) %>%
  mutate(no_rows = length(personal_id))%>%ungroup()


ausw$strata = with(ausw, reorder(strata, no_rows, median))
ausw %>% filter(!is.na(strata))%>%
  ggplot( aes(x=strata))+geom_bar()+labs(x="",y="observations",title = "Strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())
ggsave("strataplot_ausw.png", path=data_out)

#z-test between column percents each compared with each
table11<-ausw%>%tab_cells(educ_f,agegr_f,region_f,male_f, mail_f,as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+mail_f+as.factor(nationality_AUT)+as.factor(health_condition)+
                as.factor(marginal_employment)+as.factor(German_ok), data=ausw)
summary(tab1, text=TRUE)
setwd(data_out)
capture.output(summary(tab1), file="Test_ausw.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test_ausw.md", pdf_document(keep_tex=TRUE))

# exporting files for AMS; one for each wave
library("writexl")

T1<-ausw%>%ungroup()%>%filter(group_nr=="T1")%>%select(personal_id)
T2<-ausw%>%ungroup()%>%filter(group_nr=="T2")%>%select(personal_id)
T3<-ausw%>%ungroup()%>%filter(group_nr=="T3")%>%select(personal_id)
T4<-ausw%>%ungroup()%>%filter(group_nr=="T4")%>%select(personal_id)

write_xlsx(T1,paste(data_out,"ausw_Control.xlsx", sep="/"))
write_xlsx(T2,paste(data_out,"ausw_T1.xlsx", sep="/"))
write_xlsx(T3,paste(data_out,"ausw_T2.xlsx", sep="/"))
write_xlsx(T4,paste(data_out,"ausw_T3.xlsx", sep="/"))

write_xlsx(ausw, paste(data_path,"ausw_assigned.xlsx",sep="/"))
