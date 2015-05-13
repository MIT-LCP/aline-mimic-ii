/* Original cohort: no sepsis, no vaso b4 aline, no csru and ccu, no init_aline, mv before aline*/
// 901 patients
import excel "/Users/mornin/Dropbox/aLin/github/Aline/Data_Extraction/aline_mimic_data.xls", ///
sheet("Export Worksheet") firstrow case(lower) clear

//drop if vent_b4_aline==0
//drop if vent_flg ==0
drop if vent_1st_24hr==0


drop if sepsis_flg ==1

drop if vaso_flg==1

drop if initial_aline_flg ==1

drop if service_num>1



//drop if vaso_b4_aline ==1


save "/Users/mornin/Dropbox/aLin/github/Aline/Extracted Data/full_cohort_data.dta", replace


//vaso cohort, no mv
import excel "/Users/mornin/Dropbox/aLin/data/aline_mimic_data_apr14.xls", ///
sheet("Export Worksheet") firstrow case(lower) clear


drop if service_num>1
drop if initial_aline_flg ==1
//drop if sepsis_flg ==1
drop if vent_b4_aline==1
drop if vaso_flg==0
//drop if vent_flg==1

save "/Users/mornin/Dropbox/Alin/stata/April_2014/vaso_full_cohort_apr14.dta", replace


/* Sepsis cohort, no csru and ccu, no init_aline*/ //4275
import excel "/Users/mornin/Dropbox/aLin/data/aline_mimic_data_apr14.xls", ///
sheet("Export Worksheet") firstrow case(lower) clear

drop if service_num>1
drop if initial_aline_flg ==1
drop if sepsis_flg ==0

/* Sepsis cohort+mv, no csru and ccu, no init_aline*/ //4275
drop if service_num>1
drop if initial_aline_flg ==1
drop if sepsis_flg ==0

/* Table 1 for appendix */
gen ethnic_group_num=0
replace ethnic_group_num =1 if ethnic_group=="WHITE"
tabulate ethnic_group_num aline_flg, column exact

gen day_icu_intime_num_flg=0
replace day_icu_intime_num_flg=1 if day_icu_intime_num==1 | day_icu_intime_num==7
tabulate day_icu_intime_num_flg aline_flg, column exact

gen hour_icu_intime_flg=0
replace  hour_icu_intime_flg=1 if hour_icu_intime>7 & hour_icu_intime<19
tabulate hour_icu_intime_flg aline_flg, column exact

tabulate anes_flg aline_flg, column exact
tabulate fentanyl_flg aline_flg, column exact
tabulate midazolam_flg aline_flg, column exact
tabulate propofol_flg aline_flg, column exact
tabulate dilaudid_flg aline_flg, column exact


tabulate  aline_flg, column exact


summarize map_1st if aline_flg ==0 ,detail
summarize  map_1st if aline_flg ==1 ,detail
ranksum map_1st , by(aline_flg)

summarize temp_1st if aline_flg ==0 ,detail
summarize  temp_1st if aline_flg ==1 ,detail
ranksum temp_1st , by(aline_flg)

summarize hr_1st if aline_flg ==0 ,detail
summarize hr_1st  if aline_flg ==1 ,detail
ranksum  hr_1st, by(aline_flg)

summarize spo2_1st if aline_flg ==0 ,detail
summarize spo2_1st  if aline_flg ==1 ,detail
ranksum  spo2_1st, by(aline_flg)

summarize cvp_1st if aline_flg ==0 ,detail
summarize cvp_1st  if aline_flg ==1 ,detail
ranksum cvp_1st , by(aline_flg)

summarize glucose_first if aline_flg ==0 ,detail
summarize glucose_first  if aline_flg ==1 ,detail
ranksum glucose_first , by(aline_flg)

summarize calcium_first if aline_flg ==0 ,detail
summarize calcium_first  if aline_flg ==1 ,detail
ranksum  calcium_first, by(aline_flg)

summarize magnesium_first if aline_flg ==0 ,detail
summarize  magnesium_first if aline_flg ==1 ,detail
ranksum magnesium_first , by(aline_flg)

summarize phosphate_first if aline_flg ==0 ,detail
summarize phosphate_first  if aline_flg ==1 ,detail
ranksum  phosphate_first, by(aline_flg)

summarize ast_first if aline_flg ==0 ,detail
summarize ast_first  if aline_flg ==1 ,detail
ranksum ast_first , by(aline_flg)

summarize alt_first if aline_flg ==0 ,detail
summarize  alt_first if aline_flg ==1 ,detail
ranksum  alt_first, by(aline_flg)

summarize ldh_first if aline_flg ==0 ,detail
summarize ldh_first  if aline_flg ==1 ,detail
ranksum ldh_first , by(aline_flg)

summarize bilirubin_first if aline_flg ==0 ,detail
summarize bilirubin_first  if aline_flg ==1 ,detail
ranksum bilirubin_first , by(aline_flg)

summarize alp_first if aline_flg ==0 ,detail
summarize alp_first  if aline_flg ==1 ,detail
ranksum alp_first , by(aline_flg)

summarize albumin_first if aline_flg ==0 ,detail
summarize  albumin_first if aline_flg ==1 ,detail
ranksum  albumin_first, by(aline_flg)

summarize troponin_t_first if aline_flg ==0 ,detail
summarize troponin_t_first  if aline_flg ==1 ,detail
ranksum troponin_t_first , by(aline_flg)

summarize ck_first if aline_flg ==0 ,detail
summarize  ck_first if aline_flg ==1 ,detail
ranksum  ck_first, by(aline_flg)

summarize bnp_first if aline_flg ==0 ,detail
summarize bnp_first if aline_flg ==1 ,detail
ranksum bnp_first, by(aline_flg)

summarize lactate_first if aline_flg ==0 ,detail
summarize lactate_first if aline_flg ==1 ,detail
ranksum lactate_first, by(aline_flg)

summarize ph_first if aline_flg ==0 ,detail
summarize ph_first if aline_flg ==1 ,detail
ranksum ph_first, by(aline_flg)

summarize svo2_first if aline_flg ==0 ,detail
summarize svo2_first if aline_flg ==1 ,detail
ranksum svo2_first, by(aline_flg)

summarize if aline_flg ==0 ,detail
summarize  if aline_flg ==1 ,detail
ranksum , by(aline_flg)
