mcc day_28_flg_t day_28_flg_u
mcc gender_num_t gender_num_u
mcc service_num_t service_num_u

mcc chf_flg_t chf_flg_u
mcc afib_flg_t afib_flg_u
mcc renal_flg_t renal_flg_u
mcc liver_flg_t liver_flg_u
mcc copd_flg_t copd_flg_u
mcc cad_flg_t cad_flg_u
mcc stroke_flg_t stroke_flg_u
mcc mal_flg_t mal_flg_u
mcc resp_flg_t resp_flg_u
mcc ards_flg_t ards_flg_u
mcc pneumonia_flg_t pneumonia_flg_u

mcc dnr_cmo_switch_flg_t dnr_cmo_switch_flg_u
mcc dnr_adm_flg_t dnr_adm_flg_u

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





