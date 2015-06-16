/* Table 2 for appendix */

/* categorical variables */

gen ps_matched_flg = 0
replace ps_matched_flg = 1 if matched_flg>-1

gen ethnic_group_num=0
replace ethnic_group_num =1 if ethnic_group=="WHITE"

tabulate ethnic_group_num ps_matched_flg if aline_flg==0, column exact
tabulate ethnic_group_num ps_matched_flg if aline_flg==1, column exact


gen day_icu_intime_num_flg=0
replace day_icu_intime_num_flg=1 if day_icu_intime_num==1 | day_icu_intime_num==7
tabulate day_icu_intime_num_flg ps_matched_flg if aline_flg==0, column exact
tabulate day_icu_intime_num_flg ps_matched_flg if aline_flg==1, column exact

gen hour_icu_intime_flg=0
replace  hour_icu_intime_flg=1 if hour_icu_intime>7 & hour_icu_intime<19

tabulate hour_icu_intime_flg ps_matched_flg if aline_flg==0, column exact
tabulate hour_icu_intime_flg ps_matched_flg if aline_flg==1, column exact

tabulate anes_flg ps_matched_flg if aline_flg==0, column exact
tabulate anes_flg ps_matched_flg if aline_flg==1, column exact

tabulate fentanyl_flg ps_matched_flg if aline_flg==0, column exact
tabulate fentanyl_flg ps_matched_flg if aline_flg==1, column exact

tabulate midazolam_flg ps_matched_flg if aline_flg==0, column exact
tabulate midazolam_flg ps_matched_flg if aline_flg==1, column exact

tabulate propofol_flg ps_matched_flg if aline_flg==0, column exact
tabulate propofol_flg ps_matched_flg if aline_flg==1, column exact

tabulate dilaudid_flg ps_matched_flg if aline_flg==0, column exact
tabulate dilaudid_flg ps_matched_flg if aline_flg==1, column exact

tabulate gender_num ps_matched_flg if aline_flg==0, column exact
tabulate gender_num ps_matched_flg if aline_flg==1, column exact

tabulate service_num ps_matched_flg if aline_flg==0, column exact
tabulate service_num ps_matched_flg if aline_flg==1, column exact

tabulate sepsis_flg ps_matched_flg if aline_flg==0, column exact
tabulate sepsis_flg ps_matched_flg if aline_flg==1, column exact

tabulate chf_flg ps_matched_flg if aline_flg==0, column exact
tabulate chf_flg ps_matched_flg if aline_flg==1, column exact

tabulate afib_flg ps_matched_flg if aline_flg==0, column exact
tabulate afib_flg ps_matched_flg if aline_flg==1, column exact

tabulate renal_flg ps_matched_flg if aline_flg==0, column exact
tabulate renal_flg ps_matched_flg if aline_flg==1, column exact

tabulate liver_flg ps_matched_flg if aline_flg==0, column exact
tabulate liver_flg ps_matched_flg if aline_flg==1, column exact

tabulate copd_flg ps_matched_flg if aline_flg==0, column exact
tabulate copd_flg ps_matched_flg if aline_flg==1, column exact

tabulate cad_flg ps_matched_flg if aline_flg==0, column exact
tabulate cad_flg ps_matched_flg if aline_flg==1, column exact

tabulate stroke_flg ps_matched_flg if aline_flg==0, column exact
tabulate stroke_flg ps_matched_flg if aline_flg==1, column exact

tabulate mal_flg ps_matched_flg if aline_flg==0, column exact
tabulate mal_flg ps_matched_flg if aline_flg==1, column exact

tabulate resp_flg ps_matched_flg if aline_flg==0, column exact
tabulate resp_flg ps_matched_flg if aline_flg==1, column exact

tabulate ards_flg ps_matched_flg if aline_flg==0, column exact
tabulate ards_flg ps_matched_flg if aline_flg==1, column exact

tabulate pneumonia_flg ps_matched_flg if aline_flg==0, column exact
tabulate pneumonia_flg ps_matched_flg if aline_flg==1, column exact

tabulate ps_matched_flg if aline_flg==0
tabulate ps_matched_flg if aline_flg==1

tabulate ps_matched_flg aline_flg, row


/* continuous variables */

/* for aline_flg==0*/

summarize age if ps_matched_flg ==0 & aline_flg==0,detail
summarize  age if ps_matched_flg ==1 & aline_flg==0,detail
ranksum age if aline_flg==0, by(ps_matched_flg)

summarize weight_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  weight_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum weight_first if aline_flg==0, by(ps_matched_flg)

summarize sofa_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  sofa_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum sofa_first if aline_flg==0, by(ps_matched_flg)

summarize map_1st if ps_matched_flg ==0 & aline_flg==0,detail
summarize  map_1st if ps_matched_flg ==1 & aline_flg==0,detail
ranksum map_1st if aline_flg==0, by(ps_matched_flg)

summarize temp_1st if ps_matched_flg ==0 & aline_flg==0,detail
summarize  temp_1st if ps_matched_flg ==1 & aline_flg==0,detail
ranksum temp_1st  if aline_flg==0, by(ps_matched_flg)

summarize hr_1st if ps_matched_flg ==0 & aline_flg==0,detail
summarize hr_1st  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  hr_1st if aline_flg==0, by(ps_matched_flg)

summarize spo2_1st if ps_matched_flg ==0 & aline_flg==0,detail
summarize spo2_1st  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  spo2_1st if aline_flg==0, by(ps_matched_flg)

summarize cvp_1st if ps_matched_flg ==0 & aline_flg==0,detail
summarize cvp_1st  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum cvp_1st  if aline_flg==0, by(ps_matched_flg)

summarize wbc_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize wbc_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum wbc_first  if aline_flg==0, by(ps_matched_flg)

summarize hgb_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize hgb_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum hgb_first  if aline_flg==0, by(ps_matched_flg)

summarize platelet_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize platelet_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum platelet_first  if aline_flg==0, by(ps_matched_flg)

summarize sodium_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize sodium_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum sodium_first  if aline_flg==0, by(ps_matched_flg)

summarize potassium_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize potassium_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum potassium_first  if aline_flg==0, by(ps_matched_flg)

summarize tco2_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize tco2_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum tco2_first  if aline_flg==0, by(ps_matched_flg)

summarize chloride_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize chloride_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum chloride_first  if aline_flg==0, by(ps_matched_flg)

summarize bun_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize bun_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum bun_first  if aline_flg==0, by(ps_matched_flg)

summarize creatinine_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize creatinine_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum creatinine_first  if aline_flg==0, by(ps_matched_flg)


summarize glucose_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize glucose_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum glucose_first  if aline_flg==0, by(ps_matched_flg)

summarize calcium_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize calcium_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  calcium_first if aline_flg==0, by(ps_matched_flg)

summarize magnesium_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  magnesium_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum magnesium_first  if aline_flg==0, by(ps_matched_flg)

summarize phosphate_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize phosphate_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  phosphate_first if aline_flg==0, by(ps_matched_flg)

summarize ast_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize ast_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum ast_first  if aline_flg==0, by(ps_matched_flg)

summarize alt_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  alt_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  alt_first if aline_flg==0, by(ps_matched_flg)

summarize ldh_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize ldh_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum ldh_first  if aline_flg==0, by(ps_matched_flg)

summarize bilirubin_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize bilirubin_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum bilirubin_first  if aline_flg==0, by(ps_matched_flg)

summarize alp_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize alp_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum alp_first  if aline_flg==0, by(ps_matched_flg)

summarize albumin_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  albumin_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  albumin_first if aline_flg==0, by(ps_matched_flg)

summarize troponin_t_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize troponin_t_first  if ps_matched_flg ==1 & aline_flg==0,detail
ranksum troponin_t_first  if aline_flg==0, by(ps_matched_flg)

summarize ck_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize  ck_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum  ck_first if aline_flg==0, by(ps_matched_flg)

summarize bnp_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize bnp_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum bnp_first if aline_flg==0, by(ps_matched_flg)

summarize lactate_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize lactate_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum lactate_first if aline_flg==0, by(ps_matched_flg)

summarize ph_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize ph_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum ph_first if aline_flg==0, by(ps_matched_flg)

summarize svo2_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize svo2_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum svo2_first if aline_flg==0, by(ps_matched_flg)

summarize po2_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize po2_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum po2_first if aline_flg==0, by(ps_matched_flg)

summarize pco2_first if ps_matched_flg ==0 & aline_flg==0,detail
summarize pco2_first if ps_matched_flg ==1 & aline_flg==0,detail
ranksum pco2_first if aline_flg==0, by(ps_matched_flg)

/* for aline_flg==1*/

summarize age if ps_matched_flg ==0 & aline_flg==1,detail
summarize  age if ps_matched_flg ==1 & aline_flg==1,detail
ranksum age if aline_flg==1, by(ps_matched_flg)

summarize weight_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  weight_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum weight_first if aline_flg==1, by(ps_matched_flg)

summarize sofa_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  sofa_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum sofa_first if aline_flg==1, by(ps_matched_flg)

summarize map_1st if ps_matched_flg ==0 & aline_flg==1,detail
summarize  map_1st if ps_matched_flg ==1 & aline_flg==1,detail
ranksum map_1st if aline_flg==1, by(ps_matched_flg)

summarize temp_1st if ps_matched_flg ==0 & aline_flg==1,detail
summarize  temp_1st if ps_matched_flg ==1 & aline_flg==1,detail
ranksum temp_1st  if aline_flg==1, by(ps_matched_flg)

summarize hr_1st if ps_matched_flg ==0 & aline_flg==1,detail
summarize hr_1st  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  hr_1st if aline_flg==1, by(ps_matched_flg)

summarize spo2_1st if ps_matched_flg ==0 & aline_flg==1,detail
summarize spo2_1st  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  spo2_1st if aline_flg==1, by(ps_matched_flg)

summarize cvp_1st if ps_matched_flg ==0 & aline_flg==1,detail
summarize cvp_1st  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum cvp_1st  if aline_flg==1, by(ps_matched_flg)


summarize wbc_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize wbc_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum wbc_first  if aline_flg==1, by(ps_matched_flg)

summarize hgb_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize hgb_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum hgb_first  if aline_flg==1, by(ps_matched_flg)

summarize platelet_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize platelet_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum platelet_first  if aline_flg==1, by(ps_matched_flg)

summarize sodium_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize sodium_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum sodium_first  if aline_flg==1, by(ps_matched_flg)

summarize potassium_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize potassium_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum potassium_first  if aline_flg==1, by(ps_matched_flg)

summarize tco2_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize tco2_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum tco2_first  if aline_flg==1, by(ps_matched_flg)

summarize chloride_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize chloride_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum chloride_first  if aline_flg==1, by(ps_matched_flg)

summarize bun_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize bun_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum bun_first  if aline_flg==1, by(ps_matched_flg)

summarize creatinine_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize creatinine_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum creatinine_first  if aline_flg==1, by(ps_matched_flg)



summarize glucose_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize glucose_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum glucose_first  if aline_flg==1, by(ps_matched_flg)

summarize calcium_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize calcium_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  calcium_first if aline_flg==1, by(ps_matched_flg)

summarize magnesium_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  magnesium_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum magnesium_first  if aline_flg==1, by(ps_matched_flg)

summarize phosphate_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize phosphate_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  phosphate_first if aline_flg==1, by(ps_matched_flg)

summarize ast_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize ast_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum ast_first  if aline_flg==1, by(ps_matched_flg)

summarize alt_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  alt_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  alt_first if aline_flg==1, by(ps_matched_flg)

summarize ldh_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize ldh_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum ldh_first  if aline_flg==1, by(ps_matched_flg)

summarize bilirubin_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize bilirubin_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum bilirubin_first  if aline_flg==1, by(ps_matched_flg)

summarize alp_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize alp_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum alp_first  if aline_flg==1, by(ps_matched_flg)

summarize albumin_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  albumin_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  albumin_first if aline_flg==1, by(ps_matched_flg)

summarize troponin_t_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize troponin_t_first  if ps_matched_flg ==1 & aline_flg==1,detail
ranksum troponin_t_first  if aline_flg==1, by(ps_matched_flg)

summarize ck_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize  ck_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum  ck_first if aline_flg==1, by(ps_matched_flg)

summarize bnp_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize bnp_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum bnp_first if aline_flg==1, by(ps_matched_flg)

summarize lactate_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize lactate_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum lactate_first if aline_flg==1, by(ps_matched_flg)

summarize ph_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize ph_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum ph_first if aline_flg==1, by(ps_matched_flg)

summarize svo2_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize svo2_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum svo2_first if aline_flg==1, by(ps_matched_flg)

summarize po2_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize po2_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum po2_first if aline_flg==1, by(ps_matched_flg)

summarize pco2_first if ps_matched_flg ==0 & aline_flg==1,detail
summarize pco2_first if ps_matched_flg ==1 & aline_flg==1,detail
ranksum pco2_first if aline_flg==1, by(ps_matched_flg)



summarize if ps_matched_flg ==0 ,detail
summarize  if ps_matched_flg ==1 ,detail
ranksum , by(ps_matched_flg)
