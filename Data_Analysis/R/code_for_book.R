## LIBRARIES 
library(Hmisc)
library(ROCR)
library(epicalc)
library(survival)
library(pastecs)
library(Matching)

## CLEAR WORKSPACE
rm(list=ls())

## INPUT DATA
filename = c("full_cohort_data.csv")
path = c("/Users/mornin/Dropbox/aLin/github/Aline/Data_Extraction/")
data = read.csv(paste(path,filename,sep="/"))

## Descriptive stats
options(scipen=100)
options(digits=2)
stat.desc(data$age)

attach(data)
glmre <-glm(day_28_flg~
			aline_flg
			+gender_num
			+sofa_first
			+age
			+weight_first
			+service_num
			+day_icu_intime_num
			+hour_icu_intime
			+sepsis_flg
			+afib_flg
			+chf_flg
			+copd_flg
			+resp_flg
			+renal_flg
			+liver_flg
			+cad_flg
			+stroke_flg
			+mal_flg
			+map_1st
			+hr_1st
			+temp_1st
			+wbc_first
			+hgb_first
			+sodium_first
			+potassium_first
			+tco2_first
			+bun_first
			+creatinine_first
			+po2_first
			+spo2_1st
			+platelet_first
			+chloride_first
			+pco2_first
			, family = "binomial")

summary(glmre)

## Survivla analysis
survre <- survfit(Surv(mort_day_censored,!censor_flg)~aline_flg,conf.type="log-log")
summary(survre)

plot(survre, lty=1, xlab="Time", ylab="Survival Probability", xlim=c(0, 730), col = c("blue","red"))
legend(50, 0.4, c("IAC - No", "IAC - Yes") ,col = c("blue","red"), lty=1 )

survdiff(Surv(mort_day_censored,!censor_flg)~aline_flg, rho=0)

## Propensity score analysis

# Estimate the propensity model
glmre <-glm(aline_flg
            ~gender_num
            +sofa_first
            +age
            +weight_first
            +service_num
            +day_icu_intime_num
            +hour_icu_intime
            +sepsis_flg
            +afib_flg
            +chf_flg
            +copd_flg
            +resp_flg
            +renal_flg
            +liver_flg
            +cad_flg
            +stroke_flg
            +mal_flg
            +map_1st
            +hr_1st
            +temp_1st
            +wbc_first
            +hgb_first
            +sodium_first
            +potassium_first
            +tco2_first
            +bun_first
            +creatinine_first
            +po2_first
            +spo2_1st
            +platelet_first
            +chloride_first
            +pco2_first
            , family = "binomial")

#save datat objects
X <- glmre$fitted
Y <- data$day_28_flg[as.numeric(names(glmre$fitted.values))]
Tr <- data$aline_flg[as.numeric(names(glmre$fitted.values))]

# one-to-one matching with replacement (the "M=1" option).
#
rr <- Match(Y=Y,Tr=Tr,X=X, estimand='ATC', M=1, caliper=0.01)
summary(rr)
