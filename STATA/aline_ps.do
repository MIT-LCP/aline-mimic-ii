/*For mv cohort */
use "/Users/mornin/Dropbox/Alin/stata/April_2014/mv_matched_cohort_apr14.dta", clear


//logit aline_flg age gender_num weight_first sapsi_first sofa_first service_num day_icu_intime hour_icu_intime vent_12hr_flg vaso_12hr_flg anes_12hr_flg chf_flg afib_flg renal_flg liver_flg copd_flg cad_flg stroke_flg mal_flg map_1st map_lowest map_highest hr_1st hr_lowest hr_highest temp_1st temp_lowest temp_highest wbc_first wbc_lowest wbc_highest wbc_abnormal_flg hgb_first hgb_lowest hgb_highest hgb_abnormal_flg platelet_first platelet_lowest platelet_highest platelet_abnormal_flg sodium_first sodium_lowest sodium_highest sodium_abnormal_flg potassium_first potassium_lowest potassium_highest potassium_abnormal_flg tco2_first tco2_lowest tco2_highest tco2_abnormal_flg chloride_first chloride_lowest chloride_highest chloride_abnormal_flg bun_first bun_lowest bun_highest bun_abnormal_flg creatinine_first creatinine_lowest creatinine_highest creatinine_abnormal_flg 
/*logit aline_flg age gender_num weight_first sapsi_first sofa_first ///
service_num day_icu_intime_num hour_icu_intime vent_12hr_flg vaso_12hr_flg ///
anes_12hr_flg chf_flg afib_flg renal_flg liver_flg copd_flg cad_flg ///
stroke_flg mal_flg ///
map_1st map_lowest map_highest hr_1st hr_lowest hr_highest ///
temp_1st temp_lowest temp_highest ///
wbc_first wbc_lowest wbc_highest wbc_abnormal_flg ///
hgb_first hgb_lowest hgb_highest hgb_abnormal_flg ///
platelet_first platelet_lowest platelet_highest platelet_abnormal_flg ///
sodium_first sodium_lowest sodium_highest sodium_abnormal_flg ///
potassium_first potassium_lowest potassium_highest potassium_abnormal_flg ///
tco2_first tco2_lowest tco2_highest tco2_abnormal_flg ///
chloride_first chloride_lowest chloride_highest chloride_abnormal_flg ///
bun_first bun_lowest bun_highest bun_abnormal_flg ///
creatinine_first creatinine_lowest creatinine_highest creatinine_abnormal_flg
*/ 

/*i.vent_12hr_flg i.vaso_12hr_flg */

logit aline_flg i.day_icu_intime_num i.hour_icu_intime, or
lroc, nograph
estat gof, group(10) table
//auc =0.6

//Full model
logit aline_flg age i.gender_num weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first i.wbc_abnormal_flg ///
hgb_first i.hgb_abnormal_flg ///
platelet_first i.platelet_abnormal_flg ///
sodium_first i.sodium_abnormal_flg ///
potassium_first i.potassium_abnormal_flg ///
tco2_first i.tco2_abnormal_flg ///
chloride_first i.chloride_abnormal_flg ///
bun_first i.bun_abnormal_flg ///
creatinine_first i.creatinine_abnormal_flg ///
po2_first i.po2_abnormal_flg /// 
pco2_first i.pco2_abnormal_flg 

lroc, nograph
estat gof, group(10) table


program drop crossval
crossval aline_flg age i.gender_num weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first i.wbc_abnormal_flg ///
hgb_first i.hgb_abnormal_flg ///
platelet_first i.platelet_abnormal_flg ///
sodium_first i.sodium_abnormal_flg ///
potassium_first i.potassium_abnormal_flg ///
tco2_first i.tco2_abnormal_flg ///
chloride_first i.chloride_abnormal_flg ///
bun_first i.bun_abnormal_flg ///
creatinine_first i.creatinine_abnormal_flg ///
po2_first i.po2_abnormal_flg /// 
pco2_first i.pco2_abnormal_flg, numgrps(10)


//Reduced model


/*logit aline_flg sofa_first ///
i.service_num ///
i.anes_12hr_flg ///
 map_lowest ///
wbc_lowest ///
hgb_first hgb_lowest ///
i.sodium_abnormal_flg ///
potassium_first  ///
i.tco2_abnormal_flg ///
chloride_first, or*/




program drop crossval
crossval aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
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
pco2_first, numgrps(2)

graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc.gph",replace
//graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc.png",replace


logit aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
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
estat gof, group(10) table

drop phat
predict phat

//use "/Users/mornin/Dropbox/Alin/stata/aline_data_jan14.dta", clear
drop if phat==.
psmatch2 aline_flg, p(phat) cal(0.01) noreplacement
save "/Users/mornin/Dropbox/Alin/stata/April_2014/mv_matched_cohort_apr14.dta", replace
use "/Users/mornin/Dropbox/Alin/stata/April_2014/mv_matched_cohort_apr14.dta", clear

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


generate icu_los_day_cal= icu_los_day
replace icu_los_day_cal  = 17 if icu_exp_flg ==1

summarize icu_los_day_cal if aline_flg ==0,detail
summarize icu_los_day_cal if aline_flg ==1,detail
ranksum icu_los_day_cal, by(aline_flg)

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum icu_los_day if icu_exp_flg ==0, by(aline_flg)

generate hosp_los_day_cal= hospital_los_day
replace hosp_los_day_cal  = 44 if icu_exp_flg ==1

summarize hosp_los_day_cal if aline_flg ==0,detail
summarize hosp_los_day_cal if aline_flg ==1,detail
ranksum hosp_los_day_cal, by(aline_flg)

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==0,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==0,detail
ranksum hospital_los_day if icu_exp_flg ==0, by(aline_flg)

generate vent_day_cal=vent_day //31 days at 95%, remove outliers
replace vent_day_cal=45 if hosp_exp_flg ==1

summarize vent_day_cal if aline_flg ==0,detail
summarize vent_day_cal if aline_flg ==1,detail
ranksum vent_day_cal, by(aline_flg)

summarize vent_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum vent_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_free_day if aline_flg ==0 ,detail
summarize vent_free_day if aline_flg ==1 ,detail
ranksum vent_free_day, by(aline_flg)

summarize vaso_free_day if aline_flg ==0 ,detail
summarize vaso_free_day if aline_flg ==1 ,detail
ranksum vaso_free_day, by(aline_flg)

generate anes_day_cal=anes_day //31 days at 95%, remove outliers
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
ranksum anes_free_day, by(aline_flg)

generate abg_count_norm=abg_count/icu_los_day

summarize abg_count_norm if aline_flg ==0 ,detail
summarize abg_count_norm if aline_flg ==1 ,detail
ranksum abg_count_norm, by(aline_flg)

summarize fluid_day_1 if aline_flg ==0 ,detail
summarize fluid_day_1 if aline_flg ==1 ,detail
ranksum fluid_day_1, by(aline_flg)

summarize fluid_3days_raw if aline_flg ==0 ,detail
summarize fluid_3days_raw if aline_flg ==1 ,detail
ranksum fluid_3days_raw, by(aline_flg)

summarize iv_day_1 if aline_flg ==0 ,detail
summarize iv_day_1 if aline_flg ==1 ,detail
ranksum iv_day_1, by(aline_flg)

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


######### landmark study #############
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

restore


############# sepsis cohort ############


//Reduced model
logit aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
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
estat gof, group(10) table


program drop crossval
crossval aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
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
pco2_first
, numgrps(10)

graph save Graph "/Users/mornin/Dropbox/aLin/stata/Apirl_2014/aucs_sepsis_cohort.gph",replace

drop phat
predict phat

//use "/Users/mornin/Dropbox/Alin/stata/aline_data_jan14.dta", clear
drop if phat==.
psmatch2 aline_flg, p(phat) cal(0.01) noreplacement
save "/Users/mornin/Dropbox/Alin/stata/April_2014/sepsis_matched_cohort_apr14.dta", replace

logit day_28_flg i.aline_flg phat, or

drop if _weight==.

tabulate aline_flg

tabulate day_28_flg aline_flg, column exact
tabulate day_28_flg aline_flg, column chi
tabulate restraint_flg aline_flg, column exact

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum icu_los_day if icu_exp_flg ==0, by(aline_flg)

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==0,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==0,detail
ranksum hospital_los_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum vent_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_free_day if aline_flg ==0 ,detail
summarize vent_free_day if aline_flg ==1 ,detail
ranksum vent_free_day, by(aline_flg)

summarize vaso_free_day if aline_flg ==0 ,detail
summarize vaso_free_day if aline_flg ==1 ,detail
ranksum vaso_free_day, by(aline_flg)

summarize anes_day if aline_flg ==0 & icu_exp_flg ==0 & anes_flg==1,detail
summarize anes_day if aline_flg ==1 & icu_exp_flg ==0 & anes_flg==1,detail
ranksum anes_day if icu_exp_flg ==0 & anes_flg==1, by(aline_flg)

summarize anes_free_day if aline_flg ==0 & anes_flg==1,detail
summarize anes_free_day if aline_flg ==1 & anes_flg==1,detail
ranksum anes_free_day if anes_flg==1, by(aline_flg)

generate abg_count_norm=abg_count/icu_los_day

summarize abg_count_norm if aline_flg ==0 ,detail
summarize abg_count_norm if aline_flg ==1 ,detail
ranksum abg_count_norm, by(aline_flg)

summarize fluid_day_1 if aline_flg ==0 ,detail
summarize fluid_day_1 if aline_flg ==1 ,detail
ranksum fluid_day_1, by(aline_flg)

summarize fluid_3days_raw if aline_flg ==0 ,detail
summarize fluid_3days_raw if aline_flg ==1 ,detail
ranksum fluid_3days_raw, by(aline_flg)

summarize iv_day_1 if aline_flg ==0 ,detail
summarize iv_day_1 if aline_flg ==1 ,detail
ranksum iv_day_1, by(aline_flg)

summarize iv_3days_raw if aline_flg ==0 ,detail
summarize iv_3days_raw if aline_flg ==1 ,detail
ranksum iv_3days_raw, by(aline_flg)

summarize hct_lowest if aline_flg ==0 ,detail
summarize hct_lowest if aline_flg ==1 ,detail
ranksum hct_lowest, by(aline_flg)

summarize rbc_total if aline_flg ==0 ,detail
summarize rbc_total if aline_flg ==1 ,detail
ranksum rbc_total, by(aline_flg)



############# sepsis+mv cohort #############
use "/Users/mornin/Dropbox/Alin/stata/April_2014/sepsis_matched_cohort_apr14.dta", clear
drop if vent_b4_aline ==0

logit aline_flg age weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.anes_b4_aline ///
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
estat gof, group(10) table

drop phat
predict phat

drop if phat==.

psmatch2 aline_flg, p(phat) cal(0.01) noreplacement

drop if _weight==.

tabulate aline_flg

tabulate day_28_flg aline_flg, column exact
tabulate day_28_flg aline_flg, column chi
tabulate restraint_flg aline_flg, column exact

generate icu_los_day_cal= icu_los_day
replace icu_los_day_cal  = 17 if icu_exp_flg ==1

summarize icu_los_day_cal if aline_flg ==0,detail
summarize icu_los_day_cal if aline_flg ==1,detail
ranksum icu_los_day_cal, by(aline_flg)

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum icu_los_day if icu_exp_flg ==0, by(aline_flg)

generate hosp_los_day_cal= hospital_los_day
replace hosp_los_day_cal  = 44 if icu_exp_flg ==1

summarize hosp_los_day_cal if aline_flg ==0,detail
summarize hosp_los_day_cal if aline_flg ==1,detail
ranksum hosp_los_day_cal, by(aline_flg)

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==0,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==0,detail
ranksum hospital_los_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum vent_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_free_day if aline_flg ==0 ,detail
summarize vent_free_day if aline_flg ==1 ,detail
ranksum vent_free_day, by(aline_flg)

summarize vaso_day if aline_flg ==0 & icu_exp_flg ==0 & vaso_flg==1,detail
summarize vaso_day if aline_flg ==1 & icu_exp_flg ==0 & vaso_flg==1,detail
ranksum vaso_day if icu_exp_flg ==0 & vaso_flg==1, by(aline_flg)

summarize vaso_free_day if aline_flg ==0 & vaso_flg==1,detail
summarize vaso_free_day if aline_flg ==1 & vaso_flg==1,detail
ranksum vaso_free_day if vaso_flg==1, by(aline_flg)
ttest vaso_free_day if vaso_flg==1, by(aline_flg)

summarize anes_day if aline_flg ==0 & icu_exp_flg ==0 & anes_flg==1,detail
summarize anes_day if aline_flg ==1 & icu_exp_flg ==0 & anes_flg==1,detail
ranksum anes_day if icu_exp_flg ==0 & anes_flg==1, by(aline_flg)

summarize anes_free_day if aline_flg ==0 & anes_flg==1,detail
summarize anes_free_day if aline_flg ==1 & anes_flg==1,detail
ranksum anes_free_day if anes_flg==1, by(aline_flg)

generate abg_count_norm=abg_count/icu_los_day

summarize abg_count_norm if aline_flg ==0 ,detail
summarize abg_count_norm if aline_flg ==1 ,detail
ranksum abg_count_norm, by(aline_flg)

summarize fluid_day_1 if aline_flg ==0 ,detail
summarize fluid_day_1 if aline_flg ==1 ,detail
ranksum fluid_day_1, by(aline_flg)

summarize fluid_3days_raw if aline_flg ==0 ,detail
summarize fluid_3days_raw if aline_flg ==1 ,detail
ranksum fluid_3days_raw, by(aline_flg)

summarize iv_day_1 if aline_flg ==0 ,detail
summarize iv_day_1 if aline_flg ==1 ,detail
ranksum iv_day_1, by(aline_flg)

summarize iv_3days_raw if aline_flg ==0 ,detail
summarize iv_3days_raw if aline_flg ==1 ,detail
ranksum iv_3days_raw, by(aline_flg)

summarize hct_lowest if aline_flg ==0 ,detail
summarize hct_lowest if aline_flg ==1 ,detail
ranksum hct_lowest, by(aline_flg)

summarize rbc_total if aline_flg ==0 ,detail
summarize rbc_total if aline_flg ==1 ,detail
ranksum rbc_total, by(aline_flg)



############# subgroup vaso & vent #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num>2
drop if vent_flg==0 | vaso_flg==0

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==.

tabulate echo_flg


tabulate day_28_flg echo_flg, column exact


############# subgroup vent w/o vaso #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num>2

drop if vent_flg==0 
drop if vaso_flg==1
tabulate vent_flg
tabulate vaso_flg

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==.


tabulate day_28_flg echo_flg, column exact


############# subgroup vaso w/o vent #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num>2
drop if vent_flg==1 
drop if vaso_flg==0
tabulate vent_flg
tabulate vaso_flg

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==.

tabulate day_28_flg echo_flg, column exact

############# subgroup w/o vaso w/o vent #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num>2
drop if vent_flg==1 
drop if vaso_flg==1
tabulate vent_flg
tabulate vaso_flg

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact

############# subgroup micu #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num!=0

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact

############# subgroup sicu #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num!=1

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact

############# subgroup ccu #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
drop if service_num!=2

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact

############# subgroup sofa>8 #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
summarize sofa, detail
drop if sofa<=8

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact

############# subgroup sofa<=8 #############
use "/Users/mornin/Dropbox/ECHO/stata/ps_dec13.dta", clear
summarize sofa, detail
drop if sofa>8

psmatch2 echo_flg, p(phat) cal(0.01) noreplacement
drop if _weight==. 


tabulate day_28_flg echo_flg, column exact


#################### Vaso cohort ###################
use "/Users/mornin/Dropbox/Alin/stata/April_2014/vaso_matched_cohort_apr14.dta", clear

//Full model
logit aline_flg age i.gender_num weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first i.wbc_abnormal_flg ///
hgb_first i.hgb_abnormal_flg ///
platelet_first i.platelet_abnormal_flg ///
sodium_first i.sodium_abnormal_flg ///
potassium_first i.potassium_abnormal_flg ///
tco2_first i.tco2_abnormal_flg ///
chloride_first i.chloride_abnormal_flg ///
bun_first i.bun_abnormal_flg ///
creatinine_first i.creatinine_abnormal_flg ///
po2_first i.po2_abnormal_flg /// 
pco2_first i.pco2_abnormal_flg 

lroc, nograph
estat gof, group(10) table


program drop crossval
crossval aline_flg age i.gender_num weight_first sapsi_first sofa_first ///
i.service_num day_icu_intime_num hour_icu_intime ///
i.chf_flg i.afib_flg i.renal_flg i.liver_flg i.copd_flg i.cad_flg i.stroke_flg i.mal_flg i.resp_flg ///
map_1st hr_1st spo2_1st temp_1st ///
wbc_first i.wbc_abnormal_flg ///
hgb_first i.hgb_abnormal_flg ///
platelet_first i.platelet_abnormal_flg ///
sodium_first i.sodium_abnormal_flg ///
potassium_first i.potassium_abnormal_flg ///
tco2_first i.tco2_abnormal_flg ///
chloride_first i.chloride_abnormal_flg ///
bun_first i.bun_abnormal_flg ///
creatinine_first i.creatinine_abnormal_flg ///
po2_first i.po2_abnormal_flg /// 
pco2_first i.pco2_abnormal_flg, numgrps(10)


//Reduced model


/*logit aline_flg sofa_first ///
i.service_num ///
i.anes_12hr_flg ///
 map_lowest ///
wbc_lowest ///
hgb_first hgb_lowest ///
i.sodium_abnormal_flg ///
potassium_first  ///
i.tco2_abnormal_flg ///
chloride_first, or*/




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
pco2_first, numgrps(3)

graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc_vaso.gph",replace
//graph save Graph "/Users/mornin/Dropbox/aLin/stata/April_2014/roc.png",replace


logit aline_flg age weight_first sapsi_first sofa_first ///
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
pco2_first, or

lroc, nograph
estat gof, group(10) table

drop phat
predict phat

//use "/Users/mornin/Dropbox/Alin/stata/aline_data_jan14.dta", clear
drop if phat==.
psmatch2 aline_flg, p(phat) cal(0.01) noreplacement
save "/Users/mornin/Dropbox/Alin/stata/April_2014/vaso_matched_cohort_apr14.dta", replace

logit day_28_flg i.aline_flg phat, or

drop if _weight==.

tabulate aline_flg

tabulate day_28_flg aline_flg, column exact
tabulate icu_exp_flg aline_flg, column exact
tabulate hosp_exp_flg aline_flg, column exact
tabulate restraint_flg aline_flg, column exact

tabulate gender_num aline_flg, column exact
tabulate service_num aline_flg, column exact

summarize icu_los_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize icu_los_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum icu_los_day if icu_exp_flg ==0, by(aline_flg)

generate icu_los_day_cal= icu_los_day
replace icu_los_day_cal  = 42.83 if icu_exp_flg ==1

summarize icu_los_day_cal if aline_flg ==0,detail
summarize icu_los_day_cal if aline_flg ==1,detail
ranksum icu_los_day_cal, by(aline_flg)

summarize hospital_los_day if aline_flg ==0 & hosp_exp_flg ==0,detail
summarize hospital_los_day if aline_flg ==1 & hosp_exp_flg ==0,detail
ranksum hospital_los_day if icu_exp_flg ==0, by(aline_flg)

generate hospital_los_day_cal= hospital_los_day
replace hospital_los_day_cal  = 59 if hosp_exp_flg ==1

summarize hospital_los_day_cal if aline_flg ==0,detail
summarize hospital_los_day_cal if aline_flg ==1,detail
ranksum hospital_los_day_cal, by(aline_flg)

generate vent_day_cal=vent_day //31 days at 95%, remove outliers
replace vent_day_cal=45 if hosp_exp_flg ==1

summarize vent_day_cal if aline_flg ==0,detail
summarize vent_day_cal if aline_flg ==1,detail
ranksum vent_day_cal, by(aline_flg)

summarize vent_day if aline_flg ==0 & icu_exp_flg ==0,detail
summarize vent_day if aline_flg ==1 & icu_exp_flg ==0,detail
ranksum vent_day if icu_exp_flg ==0, by(aline_flg)

summarize vent_free_day if aline_flg ==0 ,detail
summarize vent_free_day if aline_flg ==1 ,detail
ranksum vent_free_day, by(aline_flg)

summarize vaso_free_day if aline_flg ==0 ,detail
summarize vaso_free_day if aline_flg ==1 ,detail
ranksum vaso_free_day, by(aline_flg)

generate vaso_day_cal=vaso_day //31 days at 95%, remove outliers
replace vaso_day_cal =18.6 if hosp_exp_flg ==1
summarize vaso_day_cal if aline_flg ==0,detail
summarize vaso_day_cal if aline_flg ==1,detail
ranksum vaso_day_cal, by(aline_flg)

generate anes_day_cal=anes_day //31 days at 95%, remove outliers
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
ranksum anes_free_day, by(aline_flg)

generate abg_count_norm=abg_count/icu_los_day

summarize abg_count_norm if aline_flg ==0 ,detail
summarize abg_count_norm if aline_flg ==1 ,detail
ranksum abg_count_norm, by(aline_flg)

summarize fluid_day_1 if aline_flg ==0 ,detail
summarize fluid_day_1 if aline_flg ==1 ,detail
ranksum fluid_day_1, by(aline_flg)

summarize fluid_3days_raw if aline_flg ==0 ,detail
summarize fluid_3days_raw if aline_flg ==1 ,detail
ranksum fluid_3days_raw, by(aline_flg)

summarize iv_day_1 if aline_flg ==0 ,detail
summarize iv_day_1 if aline_flg ==1 ,detail
ranksum iv_day_1, by(aline_flg)

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

drop sd
gen sd=mort_day
replace sd=29 if censor_flg==1 | sd>28
gen censor_flg_28 = censor_flg
replace censor_flg_28=1 if sd>28

stset sd, failure(censor_flg_28==0)
sts graph, by(aline_flg)
sts test aline_flg, logrank



