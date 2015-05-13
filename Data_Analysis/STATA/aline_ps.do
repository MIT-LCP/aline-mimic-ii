/*For mv cohort */
use "/Users/mornin/Dropbox/Alin/stata/April_2014/mv_matched_cohort_apr14.dta", clear



program drop crossval
crossval aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first ///
hgb_first ///
platelet_first ///
sodium_first ///
potassium_first ///
tco2_first ///
chloride_first ///
bun_first ///
creatinine_first ///
po2_first /// 
pco2_first, numgrps(10)

graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc.gph",replace
//graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc.png",replace


logit aline_flg age weight_first sapsi_first sofa_first ///
i.service_num i.day_icu_intime_num i.hour_icu_intime ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first ///
hgb_first ///
platelet_first ///
sodium_first ///
potassium_first ///
tco2_first ///
chloride_first ///
bun_first ///
creatinine_first ///
po2_first /// 
pco2_first, or

lroc, nograph
estat gof, group(35) table

drop phat
predict phat

save "/Users/mornin/Dropbox/Alin/stata/Sep_2014/mv_cohort_sep14.dta", replace


// historgram plots for unmatched data
dpplot phat if aline_flg==0, dist(Weibull) plot(histogram phat if aline_flg==0, bin(20))
dpplot phat if aline_flg==1, dist(Weibull) plot(histogram phat if aline_flg==1, bin(20))

betafit phat if aline_flg==0
dpplot phat if aline_flg==0, dist(beta) param(`e(alpha)' `e(beta)') plot(histogram phat if aline_flg==0, bin(20))

betafit phat if aline_flg==1
dpplot phat if aline_flg==1, dist(beta) param(`e(alpha)' `e(beta)') plot(histogram phat if aline_flg==1, bin(20))



//use "/Users/mornin/Dropbox/Alin/stata/aline_data_jan14.dta", clear
drop if phat==.

save "/Users/mornin/Dropbox/aLin/github/Aline/Data_Extraction/ps_cohort.dta", replace
use "/Users/mornin/Dropbox/aLin/github/Aline/Data_Extraction/ps_cohort.dta", clear

psmatch2 aline_flg, p(phat) cal(0.01) noreplacement

psmatch2 aline_flg, p(phat) cal(0.01)

logit day_28_flg i.aline_flg phat, or

drop if _weight==.

tabulate aline_flg

generate mort_28_flg=0
replace mort_28_flg=1 if mort_day<=28

tabulate day_28_flg aline_flg, column exact
tabulate icu_exp_flg aline_flg, column exact
tabulate hosp_exp_flg aline_flg, column exact
tabulate restraint_flg aline_flg, column exact

tabulate gender_num aline_flg, column exact
tabulate service_num aline_flg, column exact
tabulate dnr_cmo_switch_flg aline_flg, column exact

tabulate copd_flg aline_flg, column exact
tabulate chf_flg aline_flg, column exact
tabulate pneumonia_flg aline_flg, column exact
tabulate ards_flg aline_flg, column exact


logit day_28_flg i.aline_flg, or


/*generate icu_los_day_cal= icu_los_day
replace icu_los_day_cal  = 17 if icu_exp_flg ==1

summarize icu_los_day_cal if aline_flg ==0,detail
summarize icu_los_day_cal if aline_flg ==1,detail
ranksum icu_los_day_cal, by(aline_flg)*/

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum icu_los_day if icu_exp_flg ==0, by(aline_flg)
ttest icu_los_day if icu_exp_flg ==0, by(aline_flg)

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==1,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==1,detail
ranksum icu_los_day if icu_exp_flg ==1, by(aline_flg)
ttest icu_los_day if icu_exp_flg ==1, by(aline_flg)

/*generate hosp_los_day_cal= hospital_los_day
replace hosp_los_day_cal  = 44 if icu_exp_flg ==1

summarize hosp_los_day_cal if aline_flg ==0,detail
summarize hosp_los_day_cal if aline_flg ==1,detail
ranksum hosp_los_day_cal, by(aline_flg)*/

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==0,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==0,detail
ranksum hospital_los_day if hosp_exp_flg ==1, by(aline_flg)
ttest hospital_los_day if hosp_exp_flg ==0, by(aline_flg)

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==1,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==1,detail
ranksum hospital_los_day if hosp_exp_flg ==1, by(aline_flg)
ttest hospital_los_day if hosp_exp_flg ==1, by(aline_flg)

/*generate vent_day_cal=vent_day //31 days at 95%, remove outliers
replace vent_day_cal=45 if hosp_exp_flg ==1

summarize vent_day_cal if aline_flg ==0,detail
summarize vent_day_cal if aline_flg ==1,detail
ranksum vent_day_cal, by(aline_flg)*/

summarize vent_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum vent_day if icu_exp_flg ==0, by(aline_flg)
ttest vent_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_day if aline_flg ==0 & icu_exp_flg ==1,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==1,detail
ranksum vent_day if icu_exp_flg ==1, by(aline_flg)
ttest vent_day if icu_exp_flg ==1, by(aline_flg)

summarize vent_free_day if aline_flg ==0 ,detail
summarize vent_free_day if aline_flg ==1 ,detail
ranksum vent_free_day, by(aline_flg)

summarize vaso_free_day if aline_flg ==0 ,detail
summarize vaso_free_day if aline_flg ==1 ,detail
ranksum vaso_free_day, by(aline_flg)

/*generate anes_day_cal=anes_day //31 days at 95%, remove outliers
replace anes_day_cal=9.83 if hosp_exp_flg ==1
replace anes_day_cal=0 if anes_flg==0


summarize anes_day if aline_flg ==0 ,detail
summarize anes_day if aline_flg ==1,detail
ranksum anes_day, by(aline_flg)

summarize anes_day if aline_flg ==0 & icu_exp_flg ==0 & anes_flg==1,detail
summarize anes_day if aline_flg ==1 & icu_exp_flg ==0 & anes_flg==1,detail
ranksum anes_day if icu_exp_flg ==0 & anes_flg==1, by(aline_flg)

summarize anes_free_day if aline_flg ==0 ,detail
summarize anes_free_day if aline_flg ==1,detail
ranksum anes_free_day, by(aline_flg)*/

generate abg_count_norm=abg_count/icu_los_day

summarize abg_count_norm if aline_flg ==0 ,detail
summarize abg_count_norm if aline_flg ==1 ,detail
ranksum abg_count_norm, by(aline_flg)
ttest abg_count_norm, by(aline_flg)

/*summarize fluid_day_1 if aline_flg ==0 ,detail
summarize fluid_day_1 if aline_flg ==1 ,detail
ranksum fluid_day_1, by(aline_flg)

summarize fluid_3days_raw if aline_flg ==0 ,detail
summarize fluid_3days_raw if aline_flg ==1 ,detail
ranksum fluid_3days_raw, by(aline_flg)*/

summarize iv_day_1 if aline_flg ==0 ,detail
summarize iv_day_1 if aline_flg ==1 ,detail
ranksum iv_day_1, by(aline_flg)
ttest iv_day_1, by(aline_flg)

summarize iv_3days_raw if aline_flg ==0 ,detail
summarize iv_3days_raw if aline_flg ==1 ,detail
ranksum iv_3days_raw, by(aline_flg)

summarize hct_lowest if aline_flg ==0 ,detail
summarize hct_lowest if aline_flg ==1 ,detail
ranksum hct_lowest, by(aline_flg)

summarize rbc_total if aline_flg ==0 ,detail
summarize rbc_total if aline_flg ==1 ,detail
ranksum rbc_total, by(aline_flg)

summarize age if aline_flg ==0 ,detail
summarize age if aline_flg ==1 ,detail
ranksum age, by(aline_flg)

summarize sapsi_first if aline_flg ==0 ,detail
summarize sapsi_first if aline_flg ==1 ,detail
ranksum sapsi_first, by(aline_flg)

summarize sofa_first if aline_flg ==0 ,detail
summarize sofa_first if aline_flg ==1 ,detail
ranksum sofa_first, by(aline_flg)

summarize weight_first if aline_flg ==0 ,detail
summarize weight_first if aline_flg ==1 ,detail
ranksum weight_first, by(aline_flg)

summarize phat if aline_flg ==0 ,detail
summarize phat if aline_flg ==1 ,detail
ranksum phat, by(aline_flg)


######### survival study #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num>2
drop if day_28_flg ==1

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==.

tabulate echo_flg

drop sd
gen sd=mort_day
replace sd=29 if censor_flg==1 | sd>28
gen censor_flg_28 = censor_flg
replace censor_flg_28=1 if sd>28

stset sd, failure(censor_flg_28==0)
sts graph, by(aline_flg)
sts test aline_flg, logrank


// competing event cif for icu los
drop sd
gen sd=icu_los_day
replace sd=29 if sd>28
drop censor_icu_flg_28
gen censor_icu_flg_28 = 0
replace censor_icu_flg_28=1 if sd>28

drop event_flg_28
gen event_flg_28=0
replace event_flg_28=1 if censor_icu_flg_28==0
replace event_flg_28=2 if censor_flg_28==0

stset sd, failure(event_flg_28==1)
stcrreg aline_flg, compete(event_flg_28==2 )
stcurve, cif at1(aline_flg=0) at2(aline_flg=1)

// competing event cif for hospital los
drop sd
gen sd=hospital_los_day
replace sd=29 if sd>28
drop censor_hosp_flg_28
gen censor_hosp_flg_28 = 0
replace censor_hosp_flg_28=1 if sd>28

drop event_flg_28
gen event_flg_28=0
replace event_flg_28=1 if censor_hosp_flg_28==0
replace event_flg_28=2 if censor_flg_28==0

stset sd, failure(event_flg_28==1)
stcrreg aline_flg, compete(event_flg_28==2 )
stcurve, cif at1(aline_flg=0) at2(aline_flg=1)

// competing event cif for vent length
drop sd
gen sd=icu_los_day-vent_free_day
replace sd=29 if sd>28
gen censor_vent_flg_28 = 0
replace censor_vent_flg_28=1 if sd>28

drop event_flg_28
gen event_flg_28=0
replace event_flg_28=1 if censor_vent_flg_28==0
replace event_flg_28=2 if censor_flg_28==0

stset sd, failure(event_flg_28==1)
stcrreg aline_flg, compete(event_flg_28==2 )
stcurve, cif at1(aline_flg=0) at2(aline_flg=1)

/****** Aline durartion dosage effect *********/

 logit day_28_flg aline_duration age i.gender_num i.service_num sofa_first i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg if aline_flg==1, or





