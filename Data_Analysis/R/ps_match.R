## LIBRARIES
library(ROCR)
library(Matching)

## CLEAR WORKSPACE
rm(list=ls())

## INPUT DATA
setwd("~/Dropbox (Personal)/aLin/github/Aline/Data_Extraction");
ps_data<-read.csv("ps_data.csv");
#ps_data <- read.csv("~/Dropbox (Personal)/aLin/github/Aline/Data_Extraction/ps_data.csv");

data=transform(ps_data
               ,day_28_flg=factor(day_28_flg,c(0,1))
               ,gender_num=factor(gender_num, c(0,1))
               ,service_num=factor(service_num,c(0,1))
               ,day_icu_intime_num=factor(day_icu_intime_num,c(1:7))
               ,hour_icu_intime=factor(hour_icu_intime,c(0:23))
               ,chf_flg=factor(chf_flg,c(0,1))
               ,afib_flg=factor(afib_flg,c(0,1))
               ,renal_flg=factor(renal_flg,c(0,1))
               ,liver_flg=factor(liver_flg,c(0,1))
               ,copd_flg=factor(copd_flg,c(0,1))
               ,cad_flg=factor(cad_flg,c(0,1))
               ,stroke_flg=factor(stroke_flg,c(0,1))
               ,mal_flg=factor(mal_flg,c(0,1))
               ,resp_flg=factor(resp_flg,c(0,1))
               );




## logistic regression



## Full Model
# glm1=glm(aline_flg~age+gender_num+weight_first+sofa_first+service_num
#          +day_icu_intime_num+hour_icu_intime+chf_flg+afib_flg
#          +renal_flg+liver_flg+copd_flg+cad_flg+stroke_flg+mal_flg+resp_flg+map_1st
#           +hr_1st+temp_1st+spo2_1st+wbc_first+hgb_first+platelet_first+sodium_first+potassium_first
#           +tco2_first+chloride_first+bun_first+creatinine_first
#           +po2_first+pco2_first,family=binomial, data=data);

s = seq(0.01,0.1, by=0.01);
s1=seq(1,10, by=1);

p<-matrix(ncol=20, nrow=length(s));
or<-matrix(ncol=20,nrow=length(s));


pos=2;
## random Model
glm1=glm(aline_flg~sofa_first
         +service_num
         +day_icu_intime_num
         +hour_icu_intime
         +liver_flg
         +copd_flg
         +map_1st
         +hr_1st
         +temp_1st
         +spo2_1st
         +wbc_first
         +platelet_first
         +sodium_first
         +potassium_first
         +chloride_first
         +bun_first
         ,family=binomial, data=data);

#save data objects
#
X <- glm1$fitted
Y <- data$day_28_flg
Tr <- data$aline_flg



for (i in s1)
{
  # one-to-one matching with replacement (the "M=1" option).
  # Estimating the treatment effect on the treated (the "estimand" option defaults to ATT).
  #
  ps <- Match(Y=NULL, Tr=Tr, X=X, M=1, estimand='ATC', caliper=s[i], replace=FALSE);
  #summary(ps);
  index=c(ps$index.treated,ps$index.control);
  data2 <- data[index,2:3];
  
  ##logit regression to measure primary outcome effect size
  glm2 <- glm(day_28_flg~aline_flg, family=binomial, data=data2);
  
  p[i,pos]<-coef(summary(glm2))[2,4];
  r=exp(cbind(OR = coef(glm2), confint(glm2)));
  or[i,pos]<-r[2,1];
};

##plotting
y_data=vector(length=nrow(or)*ncol(or));
or_x_data=vector(length=nrow(or)*ncol(or));
p_x_data=vector(length=nrow(or)*ncol(or));
for(i in s1)
{
  start=(i-1)*ncol(or)+1;
  end=start+ncol(or)-1;
  y_data[start:end]=s[i];
  or_x_data[start:end]=t(or)[,i];
  p_x_data[start:end]=t(p)[,i];
}

plot_data=matrix(nrow=3,ncol=length(y_data));
plot_data[1,]=y_data;
plot_data[2,]=or_x_data;
plot_data[3,]=p_x_data;

write.csv(plot_data, "plotdata.csv");

