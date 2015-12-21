
  

dataset = read.csv(file="ps_cohort_full_var_ken_apr15.csv",head=TRUE,sep=",")
colnames(dataset) = tolower(colnames(dataset))


dataset$icustay_id = factor(dataset$icustay_id)
dataset$day_28_flg = factor(dataset$day_28_flg, levels=c(0,1))
dataset$gender = factor(dataset$gender, levels=c("F","M"))
dataset$hour_icu_intime = factor(dataset$hour_icu_intime)
dataset$icu_hour_flg = factor(dataset$icu_hour_flg, levels=c(0,1))
dataset$sepsis_flg = factor(dataset$sepsis_flg, levels=c(0,1))
dataset$anes_flg = factor(dataset$anes_flg, levels=c(0,1))
dataset$fentanyl_flg = factor(dataset$fentanyl_flg, levels=c(0,1))
dataset$midazolam_flg = factor(dataset$midazolam_flg, levels=c(0,1))
dataset$propofol_flg = factor(dataset$propofol_flg, levels=c(0,1))
dataset$dilaudid_flg = factor(dataset$dilaudid_flg, levels=c(0,1))
dataset$chf_flg = factor(dataset$chf_flg, levels=c(0,1))
dataset$afib_flg = factor(dataset$afib_flg, levels=c(0,1))
dataset$renal_flg = factor(dataset$renal_flg, levels=c(0,1))
dataset$liver_flg = factor(dataset$liver_flg, levels=c(0,1))
dataset$copd_flg = factor(dataset$copd_flg, levels=c(0,1))
dataset$cad_flg = factor(dataset$cad_flg, levels=c(0,1))
dataset$stroke_flg = factor(dataset$stroke_flg, levels=c(0,1))
dataset$mal_flg = factor(dataset$mal_flg, levels=c(0,1))
dataset$resp_flg = factor(dataset$resp_flg, levels=c(0,1))
dataset$ards_flg = factor(dataset$ards_flg, levels=c(0,1))
dataset$pneumonia_flg = factor(dataset$pneumonia_flg, levels=c(0,1))


library(twang)
aline.ps.ate  = ps(aline_flg ~ 
                     age + gender + ethnic_group + weight_first + bmi + sapsi_first + 
                     sofa_first + service_unit + day_icu_intime + hour_icu_intime + 
                     icu_hour_flg + sepsis_flg + anes_flg + fentanyl_flg + midazolam_flg + 
                     propofol_flg + dilaudid_flg + chf_flg + afib_flg + renal_flg + 
                     liver_flg + copd_flg + cad_flg + stroke_flg + mal_flg + resp_flg + 
                     ards_flg + pneumonia_flg + map_1st + hr_1st + temp_1st + spo2_1st + 
                     cvp_1st + wbc_first + hgb_first + platelet_first + sodium_first + 
                     potassium_first + tco2_first + chloride_first + bun_first + 
                     creatinine_first + glucose_first + calcium_first + magnesium_first + 
                     phosphate_first + ast_first + alt_first + ldh_first + bilirubin_first + 
                     alp_first + albumin_first + troponin_t_first + ck_first + bnp_first + 
                     lactate_first + ph_first + svo2_first + po2_first + pco2_first,
                   data = dataset,
                   interaction.depth = 2,
                   shrinkage = 0.01,
                   perm.test.iters = 0,
                   estimand = "ATE",
                   verbose = FALSE,
                   stop.method = c('es.mean','es.max','ks.mean','ks.max'),
                   n.trees = 10000
)


# evaluate iteration numbers for stop.method statistics
plot(aline.ps.ate, plots=1, subset = 2)
# visualize propensity score distribution and overlapping
plot(aline.ps.ate, plots=2, subset = 2)
# assessments of balance
plot(aline.ps.ate, plots=3, subset = 2)
# pairwise assessments of balance
plot(aline.ps.ate, plots=3, figureRows=1)
# p-value rank for pretreatment variables
plot(aline.ps.ate, plots=4, subset = 2)


relative.inf = summary(aline.ps.ate$gbm.obj,
                       n.trees = aline.ps.ate$desc$es.mean.ATE$n.trees,
                       plot=FALSE)

bal.table1 = bal.table(aline.ps.ate)

pretty.tab1 = bal.table1$unw[,c("tx.mn","ct.mn","p")]
names(pretty.tab1) = c("unweighted.mean.tx.g","unweighted.mean.ct.g","p-value.before")
pretty.tab2 = bal.table1$es.mean.ATE[,c("tx.mn","ct.mn","p")]
names(pretty.tab2) = c("weighted.mean.tx.g","weighted.mean.ct.g","p-value.after")
pretty.tab = cbind(pretty.tab1, pretty.tab2)

summary(aline.ps.ate)


library(survey)
dataset$weight = get.weights(aline.ps.ate, stop.method="es.mean")
design.aline.ps.ate = svydesign(ids=~1,weights=~weight,data=dataset)
logi = svyglm(day_28_flg ~ factor(aline_flg, levels=c(0,1)) + 
                service_unit + sapsi_first + sofa_first + fentanyl_flg + albumin_first +
                magnesium_first + pneumonia_flg + ck_first + stroke_flg,
              family = binomial,
              design = design.aline.ps.ate
)

summary(logi)
exp(cbind(OR=coef(logi),confint(logi)))


dataset$ps_a.line = ifelse(dataset$aline_flg ==1, 1/dataset$weight, 1-1/dataset$weight)
dataset$ps_no.a.line = ifelse(dataset$aline_flg==0,1/dataset$weight,1-1/dataset$weight)
write.csv(dataset, file="aline_dataset_with_ps.csv")

