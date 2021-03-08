library(xlsx)

##load data from all 3 waves
file_used=c("wave_1_assigned.xlsx")

wave_1<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

file_used=c("wave_2_assigned.xlsx")

wave_2<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

file_used=c("wave_3_assigned.xlsx")

wave_3<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

#create variables for unemp duration

wave_1$unemp_dur<-"3Q"
wave_2$unemp_dur<-"4Q"
wave_3$unemp_dur<-"2Q"

#create indicators for unemp dur in stratas

wave_1$strata1<-paste(wave_1$unemp_dur,wave_1$strata, sep=".")
wave_1$strata1<-as.factor(wave_1$strata1)
summary(wave_1$strata1)

wave_2$strata1<-paste(wave_2$unemp_dur,wave_2$strata, sep=".")
wave_2$strata1<-as.factor(wave_2$strata1)
summary(wave_2$strata1)

wave_3$strata1<-paste(wave_3$unemp_dur,wave_3$strata, sep=".")
wave_3$strata1<-as.factor(wave_3$strata1)
summary(wave_3$strata1)

#clean
wave_2$letzter.Beruf.6.ST.y<-NULL
wave_2$letzter.Beruf.6.ST<-wave_2$letzter.Beruf.6.ST.x
wave_2$letzter.Beruf.6.ST.x<-NULL

wave_3$letzter.Beruf.6.ST.y<-NULL
wave_3$letzter.Beruf.6.ST<-wave_3$letzter.Beruf.6.ST.x
wave_3$letzter.Beruf.6.ST.x<-NULL

#merge

full_data<-bind_rows(wave_1,wave_2,wave_3)

full_data$strata1<-as.factor(full_data$strata1)
full_data$strata1[full_data$strata1=="2Q.NA"|full_data$strata1=="3Q.NA"|full_data$strata1=="4Q.NA"]<-NA
summary(full_data$strata1)

full_data$mail<-1

#export data_frame
write_xlsx(full_data, paste(data_path,"full_data.xlsx",sep="/"))

#join those without email
file_used=c("wave_123_wo_assigned.xlsx")

wave_123_wo<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

#clean
wave_123_wo$letzter.Beruf.6.ST.y<-NULL
wave_123_wo$letzter.Beruf.6.ST<-wave_123_wo$letzter.Beruf.6.ST.x
wave_123_wo$letzter.Beruf.6.ST.x<-NULL

#indicator for no email
wave_123_wo$mail<-0

wave_123_wo$strata1<-paste("nomail",wave_123_wo$strata, sep=".")
wave_123_wo$strata1<-as.factor(wave_123_wo$strata1)
summary(wave_123_wo$strata1)

#join
full_data_1<-bind_rows(full_data, wave_123_wo)

#balance checks
#z-test between column percents each compared with each
table11<-full_data_1%>%tab_cells(educ_f,agegr_f,region_f,male_f,as.factor(unemp_dur),as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok), as.factor(mail))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+as.factor(unemp_dur)+as.factor(nationality_AUT)+as.factor(health_condition)+
                  as.factor(marginal_employment)+as.factor(German_ok)+as.factor(mail), data=full_data_1)
summary(tab1, text=TRUE)
setwd(data_out)
capture.output(summary(tab1), file="Test_f1.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test_f1.md", pdf_document(keep_tex=TRUE))

#Strata plot
full_data_1<-full_data_1 %>% group_by(strata1) %>%mutate(no_rows = length(personal_id))%>%ungroup()
full_data_1$no_rows[is.na(full_data_1$strata1)]<-NA

full_data_1$strata1 = with(full_data_1, reorder(strata1, no_rows, median))
full_data_1 %>% filter(!is.na(strata1))%>%
  ggplot( aes(x=strata1))+geom_bar()+labs(x="",y="observations",title = "strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())
ggsave("strataplot_f1.png", path=data_out)

#export data_frame
write_xlsx(full_data_1, paste(data_path,"full_data_1.xlsx",sep="/"))
