/* Original cohort: no sepsis, no vaso b4 aline, no csru and ccu, no init_aline, mv before aline*/
// 901 patients
import excel "/Users/mornin/Dropbox/aLin/data/aline_mimic_data_apr14.xls", ///
sheet("Export Worksheet") firstrow case(lower) clear


drop if service_num>1
drop if initial_aline_flg ==1
drop if sepsis_flg ==1
drop if vent_b4_aline==0
drop if vaso_flg==1
//drop if vaso_b4_aline ==1


save "/Users/mornin/Dropbox/Alin/stata/April_2014/mv_full_cohort_apr14.dta", replace


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


