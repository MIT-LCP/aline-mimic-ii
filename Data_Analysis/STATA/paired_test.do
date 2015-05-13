/* cateogrical variables*/
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

tabulate anes_flg_t
tabulate anes_flg_u
mcc anes_flg_t anes_flg_u 

tabulate fentanyl_flg_t
tabulate fentanyl_flg_u
mcc fentanyl_flg_t fentanyl_flg_u 

tabulate midazolam_flg_t
tabulate midazolam_flg_u
mcc midazolam_flg_t midazolam_flg_u

tabulate propofol_flg_t
tabulate propofol_flg_u
mcc propofol_flg_t propofol_flg_u

generate vbg_count_norm_t=vbg_count_t/icu_los_day_t
generate vbg_count_norm_u=vbg_count_u/icu_los_day_u

summarize vbg_count_norm_t, detail
summarize vbg_count_norm_u, detail
ttest vbg_count_norm_t=vbg_count_norm_u



tabulate gender_num aline_flg, column exact
tabulate service_num aline_flg, column exact
tabulate dnr_cmo_switch_flg aline_flg, column exact

tabulate copd_flg aline_flg, column exact
tabulate chf_flg aline_flg, column exact
tabulate pneumonia_flg aline_flg, column exact
tabulate ards_flg aline_flg, column exact

tabulate ethnic_group_t
tabulate ethnic_group_u

tabulate day_icu_intime_num_t
tabulate day_icu_intime_num_u

logit day_28_flg i.aline_flg, or

/*continuous variables*/
ttest age_t = age_u
ttest sofa_first_t=sofa_first_u
ttest wbc_first_t=wbc_first_u
ttest hgb_first_t=hgb_first_u
ttest platelet_first_t=platelet_first_u
ttest sodium_first_t=sodium_first_u
ttest potassium_first_t=potassium_first_u
ttest chloride_first_t=chloride_first_u
ttest bun_first_t=bun_first_u
ttest creatinine_first_t=creatinine_first_u
ttest po2_first_t=po2_first_u
ttest pco2_first_t=pco2_first_u

ttest icu_los_day_t=icu_los_day_u if icu_exp_flg_t==0 & icu_exp_flg_u==0
ttest icu_los_day_t=icu_los_day_u if icu_exp_flg_t==1 & icu_exp_flg_u==1


generate abg_count_norm_t=abg_count_t/icu_los_day_t
generate abg_count_norm_u=abg_count_u/icu_los_day_u
ttest abg_count_norm_t= abg_count_norm_u

ttest iv_day_1_t=iv_day_1_u

/* table 1 for appendix */
gen ethnic_group_num_t=0
replace ethnic_group_num_t =1 if ethnic_group_t=="WHITE"

gen ethnic_group_num_u=0
replace ethnic_group_num_u =1 if ethnic_group_u=="WHITE"

mcc ethnic_group_num_t ethnic_group_num_u

gen day_icu_intime_num_flg_t=0
replace day_icu_intime_num_flg_t=1 if day_icu_intime_num_t==1 | day_icu_intime_num_t==7

gen day_icu_intime_num_flg_u=0
replace day_icu_intime_num_flg_u=1 if day_icu_intime_num_u==1 | day_icu_intime_num_u==7

mcc day_icu_intime_num_flg_t day_icu_intime_num_flg_u

gen hour_icu_intime_flg_t=0
replace  hour_icu_intime_flg_t=1 if hour_icu_intime_t>7 & hour_icu_intime_t<19

gen hour_icu_intime_flg_u=0
replace  hour_icu_intime_flg_u=1 if hour_icu_intime_u>7 & hour_icu_intime_u<19

mcc hour_icu_intime_flg_t hour_icu_intime_flg_u

summarize weight_first_t, detail
summarize weight_first_u, detail
ttest weight_first_t=weight_first_u


summarize map_1st_t, detail
summarize map_1st_u, detail
ttest map_1st_t=map_1st_u

summarize hr_1st_t, detail
summarize hr_1st_u, detail
ttest hr_1st_t=hr_1st_u

summarize temp_1st_t, detail
summarize temp_1st_u, detail
ttest  temp_1st_t=temp_1st_u

summarize spo2_1st_t, detail
summarize spo2_1st_u, detail
ttest  spo2_1st_t=spo2_1st_u

summarize cvp_1st_t, detail
summarize cvp_1st_u, detail
ttest  cvp_1st_t=cvp_1st_u

summarize glucose_first_t, detail
summarize glucose_first_u, detail
ttest  glucose_first_t=glucose_first_u

summarize calcium_first_t, detail
summarize calcium_first_u, detail
ttest  calcium_first_t=calcium_first_u

summarize magnesium_first_t, detail
summarize magnesium_first_u, detail
ttest  magnesium_first_t=magnesium_first_u

summarize phosphate_first_t, detail
summarize phosphate_first_u, detail
ttest  phosphate_first_t=phosphate_first_u

summarize ast_first_t, detail
summarize ast_first_u, detail
ttest ast_first_t =ast_first_u

summarize alt_first_t, detail
summarize alt_first_u, detail
ttest  alt_first_t=alt_first_u

summarize ldh_first_t, detail
summarize ldh_first_u, detail
ttest  ldh_first_t=ldh_first_u

summarize bilirubin_first_t, detail
summarize bilirubin_first_u, detail
ttest  bilirubin_first_t=bilirubin_first_u

summarize alp_first_t, detail
summarize alp_first_u, detail
ttest  alp_first_t=alp_first_u

summarize albumin_first_t, detail
summarize albumin_first_u, detail
ttest  albumin_first_t=albumin_first_u

summarize troponin_t_first_t, detail
summarize troponin_t_first_u, detail
ttest  troponin_t_first_t=troponin_t_first_u

summarize ck_first_t, detail
summarize ck_first_u, detail
ttest ck_first_t =ck_first_u

//summarize bnp_first_t, detail
//summarize bnp_first_u, detail
//ttest  bnp_first_t=bnp_first_u

summarize lactate_first_t, detail
summarize lactate_first_u, detail
ttest lactate_first_t =lactate_first_u

summarize ph_first_t, detail
summarize ph_first_u, detail
ttest  ph_first_t=ph_first_u

summarize svo2_first_t, detail
summarize svo2_first_u, detail
ttest svo2_first_t =svo2_first_u

/* Table 2 */
ttest icu_los_day_t=icu_los_day_u if icu_exp_flg_t==0 & icu_exp_flg_u==0
ttest hospital_los_day_t=hospital_los_day_u if hosp_exp_flg_t==0 & hosp_exp_flg_u==0
ttest vent_day_t=vent_day_u if icu_exp_flg_t==0 & icu_exp_flg_u==0
