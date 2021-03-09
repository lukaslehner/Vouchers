library(xlsx)

##load data from lower unemp duration
file_used=c("wave_123_wo_assigned.xlsx")

wave_123_wo<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

#create indicators for unemp dur in stratas

wave_123_wo$strata1<-paste("2Q-4Q",wave_123_wo$strata, sep=".")
wave_123_wo$strata1<-as.factor(wave_123_wo$strata1)
summary(wave_123_wo$strata1)

#clean
wave_123_wo$letzter.Beruf.6.ST.y<-NULL
wave_123_wo$letzter.Beruf.6.ST<-wave_123_wo$letzter.Beruf.6.ST.x
wave_123_wo$letzter.Beruf.6.ST.x<-NULL

#indicator for no email
wave_123_wo$mail<-0

wave_123_wo$strata1<-paste("nomail",wave_123_wo$strata1, sep=".")
wave_123_wo$strata1<-as.factor(wave_123_wo$strata1)
summary(wave_123_wo$strata1)

##load data from long unemp duration
file_used=c("ausw_assigned.xlsx")

ausw<-paste(data_path, file_used, sep = "") %>% 
  read.xlsx( , 1, encoding = "UTF-8")

#clean
ausw$letzter.Beruf.6.ST.y<-NULL
ausw$letzter.Beruf.6.ST<-ausw$letzter.Beruf.6.ST.x
ausw$letzter.Beruf.6.ST.x<-NULL

#create indicators for unemp dur in stratas

ausw$strata1<-paste("1J",ausw$strata, sep=".")
ausw$strata1<-as.factor(ausw$strata1)
summary(ausw$strata1)

ausw$unemp_dur<-"1J"

#merge

full_data_2<-bind_rows(wave_123_wo,ausw)

full_data_2$strata1<-as.factor(full_data_2$strata1)
full_data_2$strata1[full_data_2$strata1=="1J.NA"|full_data_2$strata1=="nomail.2Q-4Q.NA"]<-NA
summary(full_data_2$strata1)

#export data_frame
write_xlsx(full_data_2, paste(data_path,"full_data_2.xlsx",sep="/"))

#balance checks
#z-test between column percents each compared with each
table11<-full_data_2%>%tab_cells(educ_f,agegr_f,region_f,male_f,as.factor(unemp_dur),as.factor(nationality_AUT),as.factor(health_condition),
                            as.factor(marginal_employment),as.factor(German_ok), as.factor(mail))%>%
  tab_cols(group_nr)%>%tab_stat_cpct()%>%tab_last_sig_cpct()%>%tab_pivot(stat_position = "outside_rows")

print(xtable(table11,digits=1,include.colnames=FALSE,caption = "Treatment Balance"),  include.rownames=FALSE, caption.placement = 'top')

#Chi-squared test of difference between the groups
library(arsenal)
tab1 <- tableby(group_nr ~ male_f + agegr_f+ educ_f+region_f+as.factor(unemp_dur)+as.factor(nationality_AUT)+as.factor(health_condition)+
                  as.factor(marginal_employment)+as.factor(German_ok)+as.factor(mail), data=full_data_2)
summary(tab1, text=TRUE)
setwd(data_out)
capture.output(summary(tab1), file="Test_f2.md")

## Convert R Markdown Table to LaTeX
require(knitr)
require(rmarkdown)
render("Test_f2.md", pdf_document(keep_tex=TRUE))

#Strata plot
full_data_2<-full_data_2 %>% group_by(strata1) %>%mutate(no_rows = length(personal_id))%>%ungroup()
full_data_2$no_rows[is.na(full_data_2$strata1)]<-NA

full_data_2$strata1 = with(full_data_2, reorder(strata1, no_rows, median))
full_data_2 %>% filter(!is.na(strata1))%>%
  ggplot( aes(x=strata1))+geom_bar()+labs(x="",y="observations",title = "strata sizes")+
  theme_minimal()+theme(axis.text.x=element_blank())
ggsave("strataplot_f2.png", path=data_out)


