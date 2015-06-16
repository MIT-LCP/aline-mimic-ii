/*
  
  Created on   : Dec 2012 by Mornin Feng
  Last updated : nov 2014
 Extract data for echo project and aline project

*/

--SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

--explain plan for



--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Data Extraction -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--drop table aline_mimic_data_march14;
--create table aline_mimic_data_march14 as
--create table aline_mimic_data_apr14 as

--drop table aline_mimic_data_may15;
--create table aline_mimic_data_may15 as
with population_1 as
(select * from mornin.aline_mimic_COHORT_feb14
--where icustay_id<10
--where initial_aline_flg = 0
)

--select count(distinct icustay_id) from population;
--select * from population_1; --23455


--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Demographic and basic data  -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
, population_2 as
(select distinct
pop.*
, round(icud.icustay_los/60/24, 2) as icu_los_day
, round(icud.hospital_los/60/24,2) as hospital_los_day
, case when icud.icustay_admit_age>120 then 91.4 else  icud.icustay_admit_age end as age
--, icud.gender as gender
, case when icud.gender is null then null
  when icud.gender = 'M' then 1 else 0 end as gender_num
, icud.gender as gender
, case 
when dd.ETHNICITY_DESCR like '%WHITE%' then 'WHITE'
when dd.ETHNICITY_DESCR like '%ASIAN%' then 'ASIAN'
when dd.ETHNICITY_DESCR like '%HISPANIC%' or dd.ETHNICITY_DESCR='SOUTH AMERICAN' then 'HISPANIC'
when dd.ETHNICITY_DESCR like '%WHITE%' or dd.ETHNICITY_DESCR='PORTUGUESE' then 'WHITE'
when dd.ETHNICITY_DESCR like '%BLACK%' then 'BLACK'
when dd.ETHNICITY_DESCR like '%NATIVE%' then 'NATIVE'
when dd.ETHNICITY_DESCR in ('UNKNOWN/NOT SPECIFIED', 'PATIENT DECLINED TO ANSWER', 'UNABLE TO OBTAIN') then 'UNKNOWN'
else 'OTHER'
end as ETHNIC_GROUP
--, dd.ETHNICITY_DESCR as ethnic_group
, icud.WEIGHT_FIRST
, bmi.bmi
, icud.SAPSI_FIRST
, icud.SOFA_FIRST
, icud.ICUSTAY_FIRST_SERVICE as service_unit
, case when ICUSTAY_FIRST_SERVICE='SICU' then 1
      when ICUSTAY_FIRST_SERVICE='CCU' then 2
      when ICUSTAY_FIRST_SERVICE='CSRU' then 3
      else 0 --MICU & FICU
      end
  as service_num
--, icud.icustay_intime 
, icud.icustay_outtime
, to_char(icud.ICUSTAY_INTIME, 'Day') as day_icu_intime
, to_number(to_char(icud.ICUSTAY_INTIME, 'D')) as day_icu_intime_num
, extract(hour from icud.ICUSTAY_INTIME) as hour_icu_intime
, case when icud.hospital_expire_flg='Y' then 1 else 0 end as hosp_exp_flg
, case when icud.icustay_expire_flg='Y' then 1 else 0 end as icu_exp_flg
, round((extract(day from d.dod-icud.icustay_intime)+extract(hour from d.dod-icud.icustay_intime)/24),2) as mort_day
from population_1 pop 
left join  mimic2v26.icustay_detail icud on pop.icustay_id = icud.icustay_id
left join mimic2devel.obesity_bmi bmi on bmi.icustay_id=pop.icustay_id
left join MIMIC2DEVEL.d_patients d on d.subject_id=pop.subject_id
left join mimic2v26.demographic_detail dd on dd.subject_id=pop.subject_id
)

--select distinct service_unit from population_2;
--select max(hour_icu_intime) from population_2;
--select * from population_2;


, population as
(select p.*
, case when hour_icu_intime >= 7 and hour_icu_intime<19 then 1
      else 0
    end as icu_hour_flg
, case when p.mort_day<=28 then 1 else 0 end as day_28_flg
, coalesce(p.mort_day, 731) as mort_day_censored
, case when p.mort_day<=730 then 0 else 1 end as censor_flg 
from population_2 p 
where icu_los_day>=0.5 --- stayed in icu for more than 12 hours
--and icustay_id<100
)

--select * from population; --6517


--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Aline Duration  -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


, aline_duration1 as
(select distinct p.icustay_id
, first_value(ch.charttime) over (partition by p.icustay_id order by ch.charttime asc) as aline_begintime
, first_value(ch.charttime) over (partition by p.icustay_id order by ch.charttime desc) as aline_endtime
--, ch.charttime
, p.icustay_intime
, p.icu_los_day
from population p
join mimic2v26.chartevents ch 
  on p.icustay_id=ch.icustay_id 
  and ch.itemid in (51,52)
  and (ch.value1num is not null or ch.value2num is not null)
--order by 1
)

, aline_duration as
(select 
icustay_id
, round((extract(day from (aline_endtime-aline_begintime))
    +extract(hour from  (aline_endtime-aline_begintime))/24
     +extract(minute from  (aline_endtime-aline_begintime))/24/60)/icu_los_day,2) as aline_duration
, icu_los_day
from aline_duration1
)

--select * from aline_duration;


--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Vent patients  -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

,vent_group_1 as
(select distinct 
--pop.hadm_id
pop.icustay_id
, 1 as flg
--, icud.icustay_id
--, vent.end_time
--, vent.begin_time
, min(vent.begin_time) as vent_start_time
, max(vent.end_time) as vent_end_time
,  sum(round((extract(day from (vent.end_time-vent.begin_time))+
extract(hour from (vent.end_time-vent.begin_time))/24+1/24+
extract(minute from (vent.end_time-vent.begin_time))/60/24), 3)) as vent_day
, pop.icustay_outtime
, pop.icustay_intime
, pop.INITIAL_ALINE_FLG
, pop.ALINE_FLG
, pop.ALINE_TIME_DAY
from population pop
--join mimic2v26.icustay_detail icud on icud.icustay_id = pop.icustay_id
join mimic2devel.ventilation vent on vent.icustay_id = pop.icustay_id
group by pop.icustay_id, pop.icustay_outtime, pop.icustay_intime, pop.INITIAL_ALINE_FLG, pop.ALINE_FLG, pop.ALINE_TIME_DAY
order by 1
)

--select * from vent_group_1; ---4161
--select * from vent_group where hadm_id=2798;
, vent_group_2 as
(select v.*
,  round(extract(day from (vent_start_time-icustay_intime))
        + extract(hour from (vent_start_time-icustay_intime))/24
        + extract(minute from (vent_start_time-icustay_intime))/24/60,2)  as vent_start_day
, round(extract(day from (icustay_outtime-vent_end_time))
        + extract(hour from (icustay_outtime-vent_end_time))/24
        + extract(minute from (icustay_outtime-vent_end_time))/24/60,2)  as vent_free_day
, case when vent_day>=1 then 1 else 0 end as vent_1day_flg  --no of days under vent
, case when vent_day>=0.5 then 1 else 0 end as vent_12hr_flg
, case when vent_day>=0.25 then 1 else 0 end as vent_6hr_flg
--, case when vent_start_day<=0.125 then 1 else 0 as vent_1st_3hr_flg
--, case when vent_start_day<=0.25 then 1 else 0 as vent_1st_6hr_flg
--case when vent_start_day<=0.5 then 1 else 0 as vent_1st_12hr_flg
from vent_group_1 v
)

, vent_group as
(select v.*

, case when v.vent_start_day<=(2/24) then 1 else 0 end as vent_1st_2hr_flg            
, case when v.vent_start_day<=0.125 then 1 else 0 end as vent_1st_3hr_flg
, case when v.vent_start_day<=0.25 then 1 else 0 end as vent_1st_6hr_flg
, case when v.vent_start_day<=0.5 then 1 else 0 end as vent_1st_12hr_flg
, case when v.vent_start_day<=1 then 1 else 0 end as vent_1st_24hr_flg
, case when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and vent_start_day<=ALINE_TIME_DAY then 1 
       when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and vent_start_day>ALINE_TIME_DAY then 0
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and v.vent_start_day<=(2/24) then 1
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and v.vent_start_day>(2/24) then 0
       else NULL
            end as vent_b4_aline
from vent_group_2 v
)

--select * from vent_group;
--select count(*) from vent_group where vent_b4_aline=1; --6008
--select median(vent_start_day) from vent_group;
--select count(*) from vent_group where vent_1st_3hr_flg=1; --11760 --first 3 hour started vent 7662
--select * from vent_group order by vent_free_day asc;


-------------- label vent patients at 1st 12 hour-------------------------------
--,vent_12hr_group as
--(select distinct 
----pop.hadm_id
--pop.icustay_id
--, 1 as flg
----, vent.begin_time
----, icud.icustay_intime
--from population pop
----join mimic2v26.icustay_detail icud on icud.hadm_id = pop.hadm_id and icud.icustay_seq=1
--join mimic2devel.ventilation vent 
--  on vent.icustay_id = pop.icustay_id 
--    --and vent.seq=1
--    and vent.begin_time<=pop.icustay_intime+12/24
--order by 1
--)

--select * from vent_12hr_group; --3488



--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Mediaction Dat: vasopressor & Anesthetic -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


-------------------------------------------  label vaso patients ----------------------------
--- a more accurate calculation of vaso time may be necessary!!!!!
, vaso_group_1 as
(select 
distinct 
--pop.hadm_id
pop.icustay_id
, pop.icustay_intime
, pop.icustay_outtime
--, pop.icustay_outtime-pop.icustay_intime as temp
, pop.icu_los_day
, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime asc) as begin_time
, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime desc) as end_time
, 1 as flg
, pop.INITIAL_ALINE_FLG
, pop.ALINE_FLG
, pop.ALINE_TIME_DAY
from population pop
--join mimic2v26.icustay_detail icud on icud.hadm_id = pop.hadm_id
join mimic2v26.medevents med on med.icustay_id=pop.icustay_id and med.itemid in (46,47,120,43,307,44,119,309,51,127,128)
where med.charttime is not null
)

--select extract(day from temp) as temp_day from vaso_group_1 where icustay_id=2613;
--select count(distinct icustay_id) from vaso_group;

, vaso_group_2 as
(select distinct
--hadm_id
--icustay_id
v.*
,  round(extract(day from (begin_time-icustay_intime))
        + extract(hour from (begin_time-icustay_intime))/24
        + extract(minute from (begin_time-icustay_intime))/24/60,2)  as vaso_start_day
, round(extract(day from (icustay_outtime-end_time)) 
    + extract(hour from (icustay_outtime-end_time))/24
    + extract(minute from (icustay_outtime-end_time))/60/24, 2) as vaso_free_day
, round(extract(day from (end_time-begin_time)) 
    + extract(hour from (end_time-begin_time))/24 +1/24 --- add additional 1 hour
    + extract(minute from (end_time-begin_time))/60/24, 2) as vaso_day
--, icu_los_day
--, round(extract(day from (icustay_outtime-icustay_intime)) 
--    + extract(hour from (icustay_outtime-icustay_intime))/24 
--    + extract(minute from (icustay_outtime-icustay_intime))/60/24, 2) as temp
--, flg
from vaso_group_1 v
)

, vaso_group as
(select v.*
--, case when
, case when v.vaso_start_day<=0.125 then 1 else 0 end as vaso_1st_3hr_flg
, case when v.vaso_start_day<=0.25 then 1 else 0 end as vaso_1st_6hr_flg
, case when v.vaso_start_day<=0.5 then 1 else 0 end as vaso_1st_12hr_flg 
, case when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and vaso_start_day<=ALINE_TIME_DAY then 1 
       when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and vaso_start_day>ALINE_TIME_DAY then 0
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and v.vaso_start_day<=(2/24) then 1
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and v.vaso_start_day>(2/24) then 0
       else NULL
            end as vaso_b4_aline
from vaso_group_2 v
)

--select median(vaso_start_day) from vaso_group;
--select * from vaso_group;
--select count(*) from vaso_group where vaso_b4_aline=0;--7886 -3895
--select * from vaso_group_2 where icustay_id=2613;

--, vaso_group as
--(select distinct
--icustay_id
--, flg
--, vaso_day
--, icu_los_day
--, case when (icu_los_day-vaso_day)<0 then 0 else (icu_los_day-vaso_day) end as vaso_free_Day
--from vaso_group_2
--)

--select * from vaso_group order by vaso_free_day;  ---2915

--------------  label vaso patients for 1st 12 hours ----------------------------
--, vaso_group_12_hr_1 as
--(select 
--distinct 
----pop.hadm_id
--pop.icustay_id
--, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime asc) as begin_time
--, pop.ICUSTAY_INTIME
--from population pop
----join mimic2v26.icustay_detail icud on icud.hadm_id = pop.hadm_id and ICUSTAY_SEQ =1
--join mimic2v26.medevents med on med.icustay_id=pop.icustay_id and med.itemid in (46,47,120,43,307,44,119,309,51,127,128)
--where med.charttime is not null
--order by 1
--)

--select count(distinct hadm_id) from vaso_group_12_hr_1;
--select * from vaso_group_12_hr_1; --2991


--, vaso_12hr_group as
--(select distinct icustay_id
--, 1 as flg
--from vaso_group_1
--where begin_time <= ICUSTAY_INTIME+12/24
--)

--select * from vaso_12hr_group; --2016

-------------------------------------------  label Anesthetic patients ----------------------------
, anes_group_1 as
(select 
distinct 
--pop.hadm_id
pop.icustay_id
, pop.icustay_intime
, pop.icustay_outtime
--, pop.icustay_outtime-pop.icustay_intime as temp
, pop.icu_los_day
, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime asc) as begin_time
, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime desc) as end_time
, case when med.itemid in (118,149,150,308) then 'Fentanyl'
        when med.itemid = 124 then 'Midazolam' 
        when med.itemid= 131 then 'Propofol'
        when med.itemid= 163 then 'Dilaudid'
        end as label
, 1 as flg
, pop.INITIAL_ALINE_FLG
, pop.ALINE_FLG
, pop.ALINE_TIME_DAY
from population pop
--join mimic2v26.icustay_detail icud on icud.hadm_id = pop.hadm_id
join mimic2v26.medevents med on med.icustay_id=pop.icustay_id and med.itemid in (124,118,149,150,308,163,131)
where med.charttime is not null
)

--select * from anes_group_1;

, anes_group_2 as
(select distinct
--hadm_id
--icustay_id
a.*
,  round(extract(day from (begin_time-icustay_intime))
        + extract(hour from (begin_time-icustay_intime))/24
        + extract(minute from (begin_time-icustay_intime))/24/60,2)  as anes_start_day
, round(extract(day from (icustay_outtime-end_time)) 
    + extract(hour from (icustay_outtime-end_time))/24
    + extract(minute from (icustay_outtime-end_time))/60/24, 2) as anes_free_day
, round(extract(day from (end_time-begin_time)) 
    + extract(hour from (end_time-begin_time))/24 + 1/24 -- add additional 1 hour for edge consideration
    + extract(minute from (end_time-begin_time))/60/24, 2) as anes_day
--, icu_los_day
--, round(extract(day from (icustay_outtime-icustay_intime)) 
--    + extract(hour from (icustay_outtime-icustay_intime))/24 
--    + extract(minute from (icustay_outtime-icustay_intime))/60/24, 2) as temp
--, flg
from anes_group_1 a
)

--select * from anes_group;

, anes_group as
(select a.*
--, case when
--, case when anes_start_day<=0.125 then 1 else 0 end as anes_1st_3hr_flg
--, case when anes_start_day<=0.25 then 1 else 0 end as anes_1st_6hr_flg
--, case when anes_start_day<=0.5 then 1 else 0 end as anes_1st_12hr_flg 
, case when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and anes_start_day<=ALINE_TIME_DAY then 1 
       when ALINE_FLG=1 and INITIAL_ALINE_FLG =0 and anes_start_day>ALINE_TIME_DAY then 0
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and anes_start_day<=(6/24) then 1
       when ALINE_FLG=0 and INITIAL_ALINE_FLG =0 and anes_start_day>(6/24) then 0
       else NULL
            end as anes_b4_aline
from anes_group_2 a
)

--select median(anes_start_day) from anes_group;
--select * from anes_group;

, sedative_drug as
(
select * from (
  select icustay_id,flg,label
  from anes_group
)
pivot
(
  max(flg)
  for label in ('Fentanyl' as Fentanyl, 'Midazolam' as Midazolam, 'Propofol' as Propofol, 'Dilaudid' as Dilaudid)
)
)

--select * from sedative_drug;



------------------------------------- dobutamine medication group (can be excluded) -------------------

, dabu_group_1 as
(select 
distinct 
--pop.hadm_id
pop.icustay_id
, pop.icustay_intime
--, pop.icustay_outtime
--, pop.icustay_outtime-pop.icustay_intime as temp
, pop.icu_los_day
, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime asc) as begin_time
--, first_value(med.charttime) over (partition by pop.icustay_id order by med.charttime desc) as end_time
, 1 as flg
from population pop
--join mimic2v26.icustay_detail icud on icud.hadm_id = pop.hadm_id
join mimic2v26.medevents med on med.icustay_id=pop.icustay_id and med.itemid in (306,42)
where med.charttime is not null
)

, dabu_12hr_group as
(select distinct icustay_id
, 1 as flg
from dabu_group_1
where begin_time <= ICUSTAY_INTIME+12/24
)

--select * from dabu_12hr_group; --123
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- commorbidity variables -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

, sepsis_group as
(select distinct pop.icustay_id, pop.hadm_id, 1 as flg
from population pop
join sepsis_angus sep on pop.hadm_id = sep.hadm_id
)

--select * from sepsis_group; --6339


, icd9code as
(select
pop.icustay_id
, pop.hadm_id
, regexp_substr(code,'^\D')                       AS icd9_alpha
, to_number(regexp_substr(code,'\d+$|\d+\.\d+$')) AS icd9_numeric
from population pop
join mimic2v26.icd9 icd on pop.hadm_id=icd.hadm_id
)

--select * from icd9code;

--endocarditis diagnosis group
, endocarditis_group as
(select distinct pop.hadm_id, pop.icustay_id, 1 as flg
from population pop join mimic2v26.icd9 icd on pop.hadm_id=icd.hadm_id
where icd.code in ('036.42','074.22','093.20','093.21','093.22','093.23','093.24','098.84','112.81','115.04','115.14','115.94','391.1','421.0','421.1','421.9','424.90','424.91','424.99')
)

--select count(*) from endocarditis_group; --113
--select adm.subject_id, adm.hadm_id, adm.admit_dt,dpat.dod  from mimic2v26.admissions adm,  mimic2devel.d_patients dpat where adm.subject_id=dpat.subject_id and adm.hadm_id = 9679;

, chf_group as
(select distinct pop.hadm_id,pop.icustay_id,  1 as flg
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93', '428.0', '428.1', '428.20', '428.21', '428.22', '428.23', '428.30', '428.31', '428.32', '428.33', '428.40', '428.41', '428.42', '428.43', '428.9', '428', '428.2', '428.3', '428.4')
order by 1
)
--select * from chf_group; --2518

, afib_group as
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code like '427.3%'
order by 1
)

--select count(*) from population; --6517
--select count(*) from afib_group; --1896

, renal_group as -- end stage or chronic renal disease
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code like '585.%%'
order by 1
)

--select count(*) from renal_group; --539

, liver_group as -- end stage liver disease
(select distinct pop.hadm_id, pop.icustay_id, 1 as flg
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code like '571.%%'
order by 1
)

--select count(*) from liver_group; --478

, copd_group as  --- following definition of PQI5 paper
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.code
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code in ('466.0', '490', '491.0', '491.1', '491.20', '491.21', '491.8', '491.9', '492.0', '492.8', '494', '494.0', '494.1', '496')
order by 1
)

--select * from copd_group; --1091

, cad_group as -- coronary artery disease
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.code
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code like '414.%'
order by 1
)

--select * from cad_group; --1289

, stroke_group as
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.code
--, icd9.code
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
--where icd9.code in ('398.91','402.01','402.91','404.91', '404.13', '404.93','428.0','428.1','428.9')
where icd9.code like '430%%%' or icd9.code like '431%%%' or icd9.code like '432%%%' or icd9.code like '433%%%'  or icd9.code like '434%%%'
order by 1
)

--select * from stroke_group; --616

, malignancy_group as
(select distinct icustay_id
, hadm_id
, 1 as flg
--, icd9_alpha
--, icd9_numeric
from icd9code
where icd9_alpha is null
and icd9_numeric between 140 and 239
)

--select * from malignancy_group; --1865

, resp_failure_group as
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.code
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
where icd9.code like '518.%'
order by 1
)

--select * from resp_failure_group;

, ards_group as
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.code
from population pop
join mimic2v26.icd9 icd9 on icd9.hadm_id=pop.hadm_id
where icd9.code = '518.82' or icd9.code = '518.5'
order by 1
)

--select * from ards; --1434

, pneumonia_group as
(select distinct pop.hadm_id, pop.icustay_id,  1 as flg
--, icd9.icd9_numeric as code
from population pop
join icd9code icd9 on icd9.hadm_id=pop.hadm_id
where (icd9.icd9_numeric between 486 and 488.81) 
  or (icd9.icd9_numeric>= 480 and  icd9.icd9_numeric<481)
  or (icd9.icd9_numeric>= 482 and  icd9.icd9_numeric<483) 
  or (icd9.icd9_numeric between 506 and 507.8) 
order by 1
)

--select distinct code from pneumonia_group;
--select * from pneumonia_group; --4807
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- vital signs variables -----------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
----  MAP ----
 , map_group_1 as
 (select pop.icustay_id
 , pop.icustay_intime
 , ch.charttime
 , ch.value1num as bp
 from population pop 
 left join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
    and ch.itemid in (52,456)
   --and ch.charttime <= pop.icustay_intime+3/24
  order by ch.charttime
 )
 --select count(*) from map_group_1;

 , map_group as
 (select distinct icustay_id
 , first_value(bp) over (partition by icustay_id order by charttime asc) as map_1st
 --, first_value(bp) over (partition by icustay_id order by bp asc) as map_lowest
 --, first_value(bp) over (partition by icustay_id order by bp desc) as map_highest
 from map_group_1
 where bp is not null
 )

--select count(*) from map_group; --22021

-------- Temperature -------------

 , t_group_1 as
 (select pop.icustay_id
 , ch.charttime
 , ch.value1num as temp
 from population pop 
 left join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
    and ch.itemid in (678,679)
    --and ch.charttime <= pop.icustay_intime+3/24
 )
 
 --select * from map_group;
 , t_group as
 (select distinct icustay_id
 , first_value(temp) over (partition by icustay_id order by charttime asc) as temp_1st
-- , first_value(temp) over (partition by icustay_id order by temp asc) as temp_lowest
-- , first_value(temp) over (partition by icustay_id order by temp desc) as temp_highest
 from t_group_1
 where temp is not null
 )

--select count(*) from t_group; --22007


-------- HR -------------

 , hr_group_1 as
 (select pop.icustay_id
 , ch.charttime
 , ch.value1num as hr
 from population pop 
 left join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
    and ch.itemid =211
    --and ch.charttime <= pop.icustay_intime+3/24
 )
 
 , hr_group as
 (select distinct icustay_id
 , first_value(hr) over (partition by icustay_id order by charttime asc) as hr_1st
 --, first_value(hr) over (partition by icustay_id order by hr asc) as hr_lowest
 --, first_value(hr) over (partition by icustay_id order by hr desc) as hr_highest
 from hr_group_1
 where hr is not null
 )

--select count(*) from hr_group; --22022

--select * from hr_group where hr_1st is not null;


-------- CVP -------------

 ,cvp_group_1 as
 (select pop.icustay_id
 , ch.charttime
 , ch.value1num as cvp
 from population pop 
 left join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
    and ch.itemid =113
    --and ch.charttime <= pop.icustay_intime+3/24
 )
 
 , cvp_group as
 (select distinct icustay_id
 , first_value(cvp) over (partition by icustay_id order by charttime asc) as cvp_1st
-- , first_value(cvp) over (partition by icustay_id order by cvp asc) as cvp_lowest
-- , first_value(cvp) over (partition by icustay_id order by cvp desc) as cvp_highest
 from cvp_group_1
 where cvp is not null
 )

---select * from cvp_group where cvp_1st is not null; --2176 excluded

-------- spo2 -------------

 ,spo2_group_1 as
 (select pop.icustay_id
 , ch.charttime
 , ch.value1num as spo2
 from population pop 
 left join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
    and ch.itemid =646
    --and ch.charttime <= pop.icustay_intime+3/24
 )
 
 , spo2_group as
 (select distinct icustay_id
 , first_value(spo2) over (partition by icustay_id order by charttime asc) as spo2_1st
-- , first_value(spo2) over (partition by icustay_id order by spo2 asc) as spo2_lowest
-- , first_value(spo2) over (partition by icustay_id order by spo2 desc) as spo2_highest
 from spo2_group_1
 where spo2 is not null
 )
 
--select * from spo2_group;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Lab data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

---------------  abg test count --------------------
, abg_lab as(
select distinct 
pop.icustay_id
, lab.charttime
, count(*) as labcount
from population pop
join mimic2v26.labevents lab on lab.icustay_id=pop.icustay_id
  and lab.itemid in (50016,50018,50019) and lab.value is not null
group by pop.icustay_id, lab.charttime
)

--select * from abg_lab;

, abg_count as
(select icustay_id
, count(*) as abg_count
from abg_lab
where labcount=3
group by icustay_id
)

--select * from abg_count;

---------------  vbg test count --------------------
, vbg_lab as(
select distinct 
pop.icustay_id
, ch.charttime
, count(*) as labcount
from population pop
join mimic2v26.chartevents ch on ch.icustay_id=pop.icustay_id
  and ch.itemid in (858,859,860) and ch.value1 is not null
group by pop.icustay_id, ch.charttime
)

--select * from vbg_lab;

, vbg_count as
(select icustay_id
, count(*) as vbg_count
from vbg_lab
where labcount=3
group by icustay_id
)

--select * from vbg_count;

--- HCT ---
, lab_hct_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.icustay_intime
, lab.charttime
, lab.valuenum as hct
, case when pop.gender_num=1 and lab.valuenum between 44.7 and 50.3 then 0 
      when pop.gender_num=0 and lab.valuenum between 36.1 and 44.3 then 0
      else 1 end as abnormal_flg
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50029,50383)
  and lab.valuenum is not null
order by lab.charttime
)

--select * from lab_hct_1;

, lab_hct as
(select distinct icustay_id
--, first_value(wbc) over (partition by hadm_id order by charttime asc) as wbc_first
--, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
, median(hct) over (partition by hadm_id) as hct_med
, first_value(hct) over (partition by hadm_id order by hct asc) as hct_lowest
, first_value(hct) over (partition by hadm_id order by hct desc) as hct_highest
, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) hct_abnormal_flg
from lab_hct_1
order by 1
)

--select * from lab_hct; --6399


--- WBC ---
, lab_wbc_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
--, lab.valuenum as wbc
, first_value(lab.valuenum) over (partition by pop.hadm_id order by lab.charttime asc) as wbc_first
--, case when lab.valuenum between 4.5 and 10 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50316,50468)
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
order by 1
)

--select * from lab_wbc_1;

, lab_wbc as
(select distinct icustay_id
--, first_value(wbc) over (partition by hadm_id order by charttime asc) as wbc_first
--, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(wbc) over (partition by hadm_id order by wbc asc) as wbc_lowest
--, first_value(wbc) over (partition by hadm_id order by wbc desc) as wbc_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) wbc_abnormal_flg
, wbc_first
, case when wbc_first between 4.5 and 10 then 0 else 1 end as wbc_abnormal_flg
from lab_wbc_1
order by 1
)

--select count(*) from lab_wbc; --22364

--- hemoglobin ----

, lab_hgb_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, pop.gender_num
, lab.charttime
--, lab.valuenum as hgb
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as hgb_first
--, case when pop.gender_num=1 and lab.valuenum between 13.8 and 17.2 then 0 
--       when pop.gender_num=0 and lab.valuenum between 12.1 and 15.1 then 0 
--       --when pop.gender_num is null then null
--       else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50386,50007,50184)
  --(50377,50386,50388,50391,50411,50454,50054,50003,50007,50011,50184,50183,50387,50389,50390,50412)
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  --and pop.gender_num is not null
order by 1
)

--select * from lab_hgb_1;

, lab_hgb as
(select distinct icustay_id
--, first_value(hgb) over (partition by hadm_id order by charttime asc) as hgb_first
--, first_value(hgb) over (partition by hadm_id order by hgb asc) as hgb_lowest
--, first_value(hgb) over (partition by hadm_id order by hgb desc) as hgb_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) hgb_abnormal_flg
, hgb_first
, case when gender_num=1 and hgb_first between 13.8 and 17.2 then 0 
       when gender_num=0 and hgb_first between 12.1 and 15.1 then 0 
       --when pop.gender_num is null then null
       else 1 end as hgb_abnormal_flg
from lab_hgb_1
order by 1
)

--select * from lab_hgb; 

---- platelets ---
, lab_platelet_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.itemid
--, lab.valueuom
--, lab.valuenum as platelet
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as platelet_first
--, case when lab.valuenum between 150 and 400 then 0 
--       else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50428
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)
--select distinct itemid from lab_platelet_1;
--select * from lab_platelet_1;

, lab_platelet as
(select distinct icustay_id
--, first_value(platelet) over (partition by hadm_id order by charttime asc) as platelet_first
--, first_value(platelet) over (partition by hadm_id order by platelet asc) as platelet_lowest
--, first_value(platelet) over (partition by hadm_id order by platelet desc) as platelet_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) platelet_abnormal_flg
, platelet_first
, case when platelet_first between 150 and 400 then 0 
      else 1 end as platelet_abnormal_flg
from lab_platelet_1
order by 1
)

--select * from lab_platelet;

--- sodium ---
, lab_sodium_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.itemid
, lab.valueuom
--, lab.valuenum as sodium
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as sodium_first
--, case when lab.valuenum between 135 and 145 then 0 
--       else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50159, 50012) ---- 50012 is for blood gas
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select distinct valueuom from lab_sodium_1;
--select * from lab_sodium_1 where valueuom is null;

, lab_sodium as
(select distinct icustay_id
--, first_value(sodium) over (partition by hadm_id order by charttime asc) as sodium_first
--, first_value(sodium) over (partition by hadm_id order by sodium asc) as sodium_lowest
--, first_value(sodium) over (partition by hadm_id order by sodium desc) as sodium_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) sodium_abnormal_flg
, sodium_first
, case when sodium_first between 135 and 145 then 0 
       else 1 end as sodium_abnormal_flg
from lab_sodium_1
order by 1
)

--select * from lab_sodium; --17542

--- potassium ---
, lab_potassium_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.itemid
, lab.valueuom
--, lab.valuenum as potassium
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as potassium_first
--, case when lab.valuenum between 3.7 and 5.2 then 0 
--       else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50149, 50009) ---- 50009 is from blood gas
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select distinct valueuom from lab_potassium_1;
--select * from lab_potassium_1 where valueuom is null;

, lab_potassium as
(select distinct icustay_id
--, first_value(potassium) over (partition by hadm_id order by charttime asc) as potassium_first
--, first_value(potassium) over (partition by hadm_id order by potassium asc) as potassium_lowest
--, first_value(potassium) over (partition by hadm_id order by potassium desc) as potassium_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) potassium_abnormal_flg
, potassium_first
, case when potassium_first between 3.7 and 5.2 then 0 
       else 1 end as potassium_abnormal_flg
from lab_potassium_1
order by 1
)

--select * from lab_potassium; --20665

--- bicarbonate ---
, lab_tco2_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
--, lab.itemid
, lab.valueuom
--, lab.valuenum as tco2
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as tco2_first
--, case when lab.valuenum between 22 and 28 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50172, 50025,50022) --- (50025,50022,50172) the rest are from blood gas
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select distinct valueuom from lab_tco2_1;
--select * from lab_tco2_1 where valueuom is null;

, lab_tco2 as
(select distinct icustay_id
--, first_value(tco2) over (partition by hadm_id order by charttime asc) as tco2_first
--, first_value(tco2) over (partition by hadm_id order by tco2 asc) as tco2_lowest
--, first_value(tco2) over (partition by hadm_id order by tco2 desc) as tco2_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) tco2_abnormal_flg
, tco2_first
, case when tco2_first between 22 and 28 then 0 else 1 end as tco2_abnormal_flg
from lab_tco2_1
order by 1
)

--select * from lab_tco2; --11367

--- chloride ---
, lab_chloride_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.itemid
, lab.valueuom
, lab.valuenum as chloride
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as chloride_first
--, case when lab.valuenum between 96 and 106 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50083,50004) --- 50004 is from blood gas
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select distinct valueuom from lab_chloride_1;
--select * from lab_chloride_1 where valueuom is null;

, lab_chloride as
(select distinct icustay_id
--, first_value(chloride) over (partition by hadm_id order by charttime asc) as chloride_first
--, first_value(chloride) over (partition by hadm_id order by chloride asc) as chloride_lowest
--, first_value(chloride) over (partition by hadm_id order by chloride desc) as chloride_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) chloride_abnormal_flg
, chloride_first
, case when chloride_first between 96 and 106 then 0 else 1 end as chloride_abnormal_flg
from lab_chloride_1
order by 1
)

--select * from lab_chloride; --19461

--- bun ---
, lab_bun_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
--, lab.itemid
, lab.valueuom
--, lab.valuenum as bun
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as bun_first
--, case when lab.valuenum between 6 and 20 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50177 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select * from lab_bun_1;

, lab_bun as
(select distinct icustay_id
--, first_value(bun) over (partition by hadm_id order by charttime asc) as bun_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(bun) over (partition by hadm_id order by bun asc) as bun_lowest
--, first_value(bun) over (partition by hadm_id order by bun desc) as bun_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) bun_abnormal_flg
, bun_first
, case when bun_first between 6 and 20 then 0 else 1 end as bun_abnormal_flg
from lab_bun_1
order by 1
)

--select * from lab_bun; --19027

--- creatinine ---
, lab_creatinine_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, pop.gender_num
, lab.charttime
, lab.valueuom
--, lab.valuenum as creatinine
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as creatinine_first
--, case when pop.gender_num=1 and lab.valuenum <= 1.3 then 0 
--       when pop.gender_num=0 and lab.valuenum <= 1.1 then 0 
--        else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50090 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  --and pop.gender_num is not null
order by 1
)

--select * from lab_creatinine_1;

, lab_creatinine as
(select distinct icustay_id
--, first_value(creatinine) over (partition by hadm_id order by charttime asc) as creatinine_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(creatinine) over (partition by hadm_id order by creatinine asc) as creatinine_lowest
--, first_value(creatinine) over (partition by hadm_id order by creatinine desc) as creatinine_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) creatinine_abnormal_flg
, creatinine_first
, case when gender_num=1 and creatinine_first <= 1.3 then 0 
       when gender_num=0 and creatinine_first <= 1.1 then 0 
        else 1 end as creatinine_abnormal_flg
from lab_creatinine_1
order by 1
)

--select * from lab_creatinine; --19027


--- glucose ---
, lab_glucose as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as glucose_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid in (50006,50112)
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_glucose;


--- calcium ---
, lab_calcium as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as calcium_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50079
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_calcium;

--- magnesium ---
, lab_magnesium as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as magnesium_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50140
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_magnesium;


--- phosphate ---
, lab_phosphate as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as phosphate_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50148
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_phosphate;


--- AST ---
, lab_AST as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as AST_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50073
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_AST;

--- ALT ---
, lab_ALT as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as ALT_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50062
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_ALT;


--- LDH ---
, lab_LDH as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as LDH_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50134
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_LDH;

--- bilirubin ---
, lab_bilirubin as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as bilirubin_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50170
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_bilirubin;



-- ALP ---
, lab_ALP as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as ALP_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50061
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_ALP;

-- albumin ---
, lab_albumin as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as albumin_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50060
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_albumin;

-- troponin_t ---
, lab_troponin_t as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as troponin_t_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50189
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_troponin_t;


-- CK ---
, lab_CK as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as CK_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50087
  and lab.valuenum is not null
  --and pop.gender_num is not null
order by 1
)

--select * from lab_CK;

-- BNP ---
, lab_BNP as
(select distinct pop.hadm_id
, pop.icustay_id
, lab.valueuom
--, lab.value
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as BNP_first
from population pop
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50195
  --and lab.valuenum is not null
order by 1
)

--select * from lab_BNP;

--- Lactate ---
, lab_lactate_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.valueuom
--, lab.valuenum as lactate
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as lactate_first
--, case when lab.valuenum between 0.5 and 2.2 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50010 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select * from lab_lactate_1;

, lab_lactate as
(select distinct icustay_id
--, first_value(lactate) over (partition by hadm_id order by charttime asc) as lactate_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(lactate) over (partition by hadm_id order by lactate asc) as lactate_lowest
--, first_value(lactate) over (partition by hadm_id order by lactate desc) as lactate_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) lactate_abnormal_flg
, lactate_first
--, case when lactate_first between 0.5 and 2.2 then 0 else 1 end as lactate_abnormal_flg
from lab_lactate_1
order by 1
)

--select * from lab_lactate; --9747

--- PH ---
, lab_ph_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.valueuom
--, lab.valuenum as ph
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as ph_first
--, case when lab.valuenum between 7.38 and 7.42 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50018 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select * from lab_ph_1;

, lab_ph as
(select distinct icustay_id
--, first_value(ph) over (partition by hadm_id order by charttime asc) as ph_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(ph) over (partition by hadm_id order by ph asc) as ph_lowest
--, first_value(ph) over (partition by hadm_id order by ph desc) as ph_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) ph_abnormal_flg
, ph_first
, case when ph_first between 7.38 and 7.42 then 0 else 1 end as ph_abnormal_flg
from lab_ph_1
order by 1
)

--select * from lab_ph; --13266



----- SVO2 ---
, lab_svo2 as
(select distinct
pop.icustay_id
--, icud.ICUSTAY_INTIME
--, ch.charttime
, first_value(ch.value1num) over (partition by pop.icustay_id order by ch.charttime asc) as svo2_first
--, case when ch.value1num between 60 and 80 then 0 else 1 end as abnormal_flg
from population pop
join mimic2v26.chartevents ch 
  on pop.icustay_id=ch.icustay_id 
  and ch.itemid in (664,838)
  and ch.value1num is not null
  --and ch.charttime<=icud.ICUSTAY_INTIME+12/24
order by 1
)

--select * from lab_svo2_1;

--, lab_svo2 as
--(select distinct hadm_id
--, first_value(svo2) over (partition by hadm_id order by svo2 asc) as svo2_lowest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_svo2_1
--order by 1
--)

--select * from lab_svo2; --471 (not to be included)


--- po2 ---
, lab_po2_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.valueuom
--, lab.valuenum as po2
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as po2_first
--, case when lab.valuenum between 75 and 100 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50019 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select * from lab_po2_1;

, lab_po2 as
(select distinct icustay_id
--, first_value(po2) over (partition by hadm_id order by charttime asc) as po2_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(po2) over (partition by hadm_id order by po2 asc) as po2_lowest
--, first_value(po2) over (partition by hadm_id order by po2 desc) as po2_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) po2_abnormal_flg
, po2_first
, case when po2_first between 75 and 100 then 0 else 1 end as po2_abnormal_flg
from lab_po2_1
order by 1
)

--select * from lab_po2; --12784

--- paco2 ---
, lab_pco2_1 as
(select pop.hadm_id
, pop.icustay_id
, pop.ICUSTAY_INTIME
, lab.charttime
, lab.valueuom
--, lab.valuenum as pco2
, first_value(lab.valuenum) over (partition by pop.hadm_id order by charttime asc) as pco2_first
--, case when lab.valuenum between 35 and 45 then 0 else 1 end as abnormal_flg
from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
join mimic2v26.labevents lab 
  on pop.hadm_id=lab.hadm_id 
  and lab.itemid = 50016 
  and lab.valuenum is not null
  --and lab.charttime<=pop.ICUSTAY_INTIME+3/24
  ----and pop.gender_num is not null
order by 1
)

--select * from lab_pco2_1;

, lab_pco2 as
(select distinct icustay_id
--, first_value(pco2) over (partition by hadm_id order by charttime asc) as pco2_first
----, first_value(abnormal_flg) over (partition by hadm_id order by chartime asc) as wbs_first_abn_flg
--, first_value(pco2) over (partition by hadm_id order by pco2 asc) as pco2_lowest
--, first_value(pco2) over (partition by hadm_id order by pco2 desc) as pco2_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) pco2_abnormal_flg
, pco2_first
, case when pco2_first between 35 and 45 then 0 else 1 end as pco2_abnormal_flg
from lab_pco2_1
order by 1
)

--select * from lab_pco2; --12782

--- Troponin T--- 
--, lab_troponin_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, lab.charttime
--, lab.valuenum as troponin
--, case when lab.valuenum <= 0.1 then 0
--        else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud 
--  on pop.hadm_id=icud.hadm_id 
--  and icud.ICUSTAY_SEQ =1 
----  and icud.gender is not null
--join mimic2v26.labevents lab 
--  on pop.hadm_id=lab.hadm_id 
--  and lab.itemid in (50189)
--  and lab.valuenum is not null
--  and lab.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)


--select * from lab_troponin_t; --2124



----- SVO2 ---
--, lab_svo2_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, ch.charttime
--, ch.value1num as svo2
--, case when ch.value1num between 60 and 80 then 0 else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud on pop.hadm_id=icud.hadm_id and ICUSTAY_SEQ =1
--join mimic2v26.chartevents ch 
--  on icud.icustay_id=ch.icustay_id 
--  and ch.itemid in (664,838)
--  and ch.value1num is not null
--  and ch.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)
--
----select * from lab_svo2_1;
--
--, lab_svo2 as
--(select distinct hadm_id
--, first_value(svo2) over (partition by hadm_id order by svo2 asc) as svo2_lowest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_svo2_1
--order by 1
--)
--
----select * from lab_svo2; --471 (not to be included)

----- BNP --- should be excluded
--, lab_bnp_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, lab.charttime
--, lab.valuenum as bnp
--, case when lab.valuenum <= 100 then 0
--        else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud 
--  on pop.hadm_id=icud.hadm_id 
--  and icud.ICUSTAY_SEQ =1 
----  and icud.gender is not null
--join mimic2v26.labevents lab 
--  on pop.hadm_id=lab.hadm_id 
--  and lab.itemid in (50195)
--  and lab.valuenum is not null
--  and lab.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)
--
----select * from lab_bnp_1;
--
--, lab_bnp as
--(select distinct hadm_id
--, first_value(bnp) over (partition by hadm_id order by bnp desc) as bnp_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_bnp_1
--order by 1
--)
--
----select * from lab_bnp; --346 

----- Troponin T--- 
--, lab_troponin_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, lab.charttime
--, lab.valuenum as troponin
--, case when lab.valuenum <= 0.1 then 0
--        else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud 
--  on pop.hadm_id=icud.hadm_id 
--  and icud.ICUSTAY_SEQ =1 
----  and icud.gender is not null
--join mimic2v26.labevents lab 
--  on pop.hadm_id=lab.hadm_id 
--  and lab.itemid in (50189)
--  and lab.valuenum is not null
--  and lab.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)
--
----select * from lab_troponin_1;
--
--, lab_troponin_t as
--(select distinct hadm_id
--, first_value(troponin) over (partition by hadm_id order by troponin desc) as troponin_t_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_troponin_1
--order by 1
--)
--
----select * from lab_troponin_t; --2124
--
----- Troponin I--- 
--, lab_troponin_i_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, lab.charttime
--, lab.valuenum as troponin
--, case when lab.valuenum <= 10 then 0
--        else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud 
--  on pop.hadm_id=icud.hadm_id 
--  and icud.ICUSTAY_SEQ =1 
----  and icud.gender is not null
--join mimic2v26.labevents lab 
--  on pop.hadm_id=lab.hadm_id 
--  and lab.itemid in (50188)
--  and lab.valuenum is not null
--  and lab.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)
--
----select * from lab_troponin_1;
--
--, lab_troponin_i as
--(select distinct hadm_id
--, first_value(troponin) over (partition by hadm_id order by troponin desc) as troponin_i_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_troponin_i_1
--order by 1
--)
--
----select distinct hadm_id from (
----select * from lab_troponin_i
----union
----select * from lab_troponin_t); --2552
--
----- CK test--- 
--, lab_ck_1 as
--(select pop.hadm_id
--, icud.ICUSTAY_INTIME
--, lab.charttime
--, lab.valuenum as ck
--, case when lab.valuenum <= 120 then 0
--        else 1 end as abnormal_flg
--from population pop
--join mimic2v26.icustay_detail icud 
--  on pop.hadm_id=icud.hadm_id 
--  and icud.ICUSTAY_SEQ =1 
----  and icud.gender is not null
--join mimic2v26.labevents lab 
--  on pop.hadm_id=lab.hadm_id 
--  and lab.itemid in (50087)
--  and lab.valuenum is not null
--  and lab.charttime<=icud.ICUSTAY_INTIME+12/24
--order by 1
--)
--
----select * from lab_ck_1;
--
--, lab_ck as
--(select distinct hadm_id
--, first_value(ck) over (partition by hadm_id order by ck desc) as ck_highest
--, first_value(abnormal_flg) over (partition by hadm_id order by abnormal_flg desc) as abnormal_flg
--from lab_ck_1
--order by 1
--)
--
----select * from lab_ck; --2948

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Procedure data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

---- use of restraints and reasons ----
, restraint_group as
(select distinct pop.icustay_id
--, ch.charttime
--, ch.value1
, 1 as flg
from population pop
join mimic2v26.chartevents ch 
  on ch.icustay_id=pop.icustay_id 
  and ch.itemid=605
  and ch.value1='Ext/TXInterfere'
)

--select * from restraint_group; --11719

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Care code data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

---- care code ----
, code_adm as
(select 
distinct pop.icustay_id
, first_value(ch.value1) over (partition by ch.icustay_id order by ch.charttime asc) as first_code
from population pop 
join mimic2v26.chartevents ch 
  on ch.icustay_id=pop.icustay_id 
  and ch.itemid=128
  and ch.value1 is not null
--and lower(value1) like '%resuscita%'
)

--select * from dnr_adm_1;
, dnr_adm as
(select distinct icustay_id
--, first_code
, 1 as flg
from code_adm
where lower(first_code) like '%resuscita%'
)

--select * from dnr_adm;--961

, dnr as
(select 
distinct pop.icustay_id
, 1 as flg
from population pop 
join mimic2v26.chartevents ch 
  on ch.icustay_id=pop.icustay_id 
  and ch.itemid=128
  and lower(value1) like '%resuscita%'
)

--select count(*) from dnr; --2561
, dnr_switch as
(select * from dnr
minus
select * from dnr_adm
)

--select * from dnr_switch; --1600


, cmo as
(select 
distinct pop.icustay_id
--, value1
, 1 as flg
from population pop 
join mimic2v26.chartevents ch 
  on ch.icustay_id=pop.icustay_id 
  and ch.itemid=128
  and lower(value1) like '%comfort%'
)

--select * from cmo; --910
, cmo_adm as
(select  distinct icustay_id
--, first_code
, 1 as flg
from code_adm
where lower(first_code) like '%comfort%'
)

--select * from cmo_adm; --15

, cmo_switch as
(select * from cmo
minus
select * from cmo_adm
)

--select * from cmo_switch; --895

, dnr_cmo_switch as
(select distinct icustay_id, flg
from (
  select * from cmo_switch
    union
  select * from dnr_switch
)
)

--select * from dnr_cmo_switch; --2053

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Fluid data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

--- fluid in for the first 3 days ---
, fluid_in_1 as
(select distinct pop.icustay_id
, bal.charttime
--, first_value(bal.cumvolume) over (partition by pop.icustay_id order by bal.charttime asc) as fluid_day_1
, bal.cumvolume as fluid_day_1
, lead(bal.cumvolume,1) over (partition by pop.icustay_id order by bal.charttime asc) as fluid_day_2
, lead(bal.cumvolume,2) over (partition by pop.icustay_id order by bal.charttime asc) as fluid_day_3
from population pop
join mimic2v26.TOTALBALEVENTS bal 
  on pop.icustay_id=bal.icustay_id 
  and bal.itemid in (1,3151)  -- total 24 hour fluid in (1,3151)
order by 1
)

--select * from fluid_in_1;

, fluid_in_2 as
(select distinct icustay_id
, first_value(fluid_day_1) over (partition by icustay_id order by charttime asc) as fluid_day_1
, first_value(fluid_day_2) over (partition by icustay_id order by charttime asc) as fluid_day_2
, first_value(fluid_day_3) over (partition by icustay_id order by charttime asc) as fluid_day_3
--, first_value(rownum) over (partition by icustay_id order by icustay_id, charttime asc) as first_rownum
from fluid_in_1 f
order by 1
)

--select * from fluid_in_2;

--, fluid_in as
--(select icustay_id, fluid_day_1, fluid_day_2, fluid_day_3, (fluid_day_1+fluid_day_2+fluid_day_3) as fluid_3days
--from 
--  (select icustay_id
--  , coalesce(fluid_day_1,0) as fluid_day_1
--  , coalesce(fluid_day_2,0) as fluid_day_2
--  , coalesce(fluid_day_3,0) as fluid_day_3
--  --, (fluid_day_1+fluid_day_2+fluid_day_3) as fluid_3days
--  from fluid_in_2
--  )
--)
----select * from fluid_in;

, fluid_in as
(select f.*
, fluid_day_1+fluid_day_2+fluid_day_3 as fluid_3days_raw
, coalesce(fluid_day_1,0)+coalesce(fluid_day_2,0)+coalesce(fluid_day_3,0) as fluid_3days_clean
from fluid_in_2 f
)

--select * from fluid_in;
------------ IV infusion ------------

, IV_in_1 as
(select distinct pop.icustay_id
, bal.charttime
--, first_value(bal.cumvolume) over (partition by pop.icustay_id order by bal.charttime asc) as fluid_day_1
, bal.cumvolume as IV_day_1
, lead(bal.cumvolume,1) over (partition by pop.icustay_id order by bal.charttime asc) as IV_day_2
, lead(bal.cumvolume,2) over (partition by pop.icustay_id order by bal.charttime asc) as IV_day_3
from population pop
join mimic2v26.TOTALBALEVENTS bal 
  on pop.icustay_id=bal.icustay_id 
  and bal.itemid in (18,3155)  -- total 24 hour fluid in (1,3151)
order by 1
)

--select * from fluid_in_1;

, IV_in_2 as
(select distinct icustay_id
, first_value(IV_day_1) over (partition by icustay_id order by charttime asc) as IV_day_1
, first_value(IV_day_2) over (partition by icustay_id order by charttime asc) as IV_day_2
, first_value(IV_day_3) over (partition by icustay_id order by charttime asc) as IV_day_3
--, first_value(rownum) over (partition by icustay_id order by icustay_id, charttime asc) as first_rownum
from IV_in_1 f
order by 1
)

--select * from fluid_in_2;

--, IV_in as
--(select icustay_id, IV_day_1, IV_day_2, IV_day_3, (IV_day_1+IV_day_2+IV_day_3) as IV_3days
--from 
--  (select icustay_id
--  , coalesce(IV_day_1,0) as IV_day_1
--  , coalesce(IV_day_2,0) as IV_day_2
--  , coalesce(IV_day_3,0) as IV_day_3
--  --, (fluid_day_1+fluid_day_2+fluid_day_3) as fluid_3days
--  from IV_in_2
--  )
--)
--select * from IV_in;

, IV_in as
(select v.*
, IV_day_1+IV_day_2+IV_day_3 as IV_3days_raw
, coalesce(IV_day_1,0)+coalesce(IV_day_2,0)+coalesce(IV_day_3,0) as IV_3days_clean
from IV_in_2 v
)

--select * from IV_in;


--------- rbc package --------------
, rbc_day_1 as
(select distinct pop.icustay_id
, sum(io.volume) as rbc_day_1
from population pop
join MIMIC2V26.ioevents io 
  on pop.icustay_id=io.icustay_id
  and io.charttime<=pop.icustay_intime+1
  and io.volume is not null
join MIMIC2V26.d_ioitems d 
  on io.itemid=d.itemid 
  and lower(d.label) like '%rbc%' 
  and lower(d.category) like '%infusions%'
group by pop.icustay_id
)

, rbc_total as
(select distinct pop.icustay_id
, sum(io.volume) as rbc_total
from population pop
join MIMIC2V26.ioevents io 
  on pop.icustay_id=io.icustay_id
  --and io.charttime<=pop.icustay_intime+1
  and io.volume is not null
join MIMIC2V26.d_ioitems d 
  on io.itemid=d.itemid 
  and lower(d.label) like '%rbc%' 
  and lower(d.category) like '%infusions%'
group by pop.icustay_id
)

--select * from rbc_total;

--select * from rbc_in;
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Combined data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

, aline_data as
(select distinct
pop.*

, coalesce(vent.flg,0) as vent_flg
--, coalesce(vent.vent_1day_flg,0) as vent_1day_flg
, coalesce(vent.vent_1st_12hr_flg,0) as vent_1st_12hr
, coalesce(vent.vent_1st_24hr_flg,0) as vent_1st_24hr
, coalesce(vent.vent_b4_aline,0) as vent_b4_aline
, case when vent.vent_day is null then 0 else vent.vent_day end as vent_day
, case when vent.vent_free_day is null then pop.icu_los_day else vent.vent_free_day  end as vent_free_day
--, coalesce(vent12.flg,0) as vent_12hr_flg
, coalesce(vaso.flg,0) as vaso_flg
, case when vaso.vaso_day is null then 0 else vaso.vaso_day end as vaso_day
, case when vaso.vaso_free_day is null then pop.icu_los_day else vaso.vaso_free_day  end as vaso_free_day
--, coalesce(vaso12.flg,0) as vaso_12hr_flg
, coalesce(vaso.vaso_b4_aline,0) as vaso_b4_aline
, coalesce(anes.flg,0) as anes_flg
, case when anes.anes_day is null then 0 else anes.anes_day end as anes_day
, case when anes.anes_free_day is null then pop.icu_los_day else anes.anes_free_day  end as anes_free_day
--, coalesce(anes12.flg,0) as anes_12hr_flg
, coalesce(anes.anes_b4_aline,0) as anes_b4_aline
, coalesce(sed.fentanyl,0) as fentanyl_flg
, coalesce(sed.midazolam,0) as midazolam_flg
, coalesce(sed.propofol,0) as propofol_flg
, coalesce(sed.dilaudid,0) as dilaudid_flg


, coalesce(sep.flg,0) as sepsis_flg
, coalesce(chf.flg,0) as chf_flg
, coalesce(afib.flg,0) as afib_flg
, coalesce(renal.flg,0) as renal_flg
, coalesce(liver.flg,0) as liver_flg
, coalesce(copd.flg,0) as copd_flg
, coalesce(cad.flg,0) as cad_flg
, coalesce(stroke.flg,0) as stroke_flg
, coalesce(mal.flg,0) as mal_flg
, coalesce(resp.flg,0) as resp_flg
, coalesce(ards.flg,0) as ards_flg
, coalesce(pne.flg,0) as pneumonia_flg

--
, m.map_1st
--, m.map_lowest
--, m.map_highest
, hr.hr_1st
--, hr.hr_lowest
--, hr.hr_highest
, t.temp_1st
--, t.temp_lowest
--, t.temp_highest
, spo2.spo2_1st
--, spo2.spo2_lowest
--, spo2.spo2_highest
, cvp.cvp_1st
----, cvp.cvp_lowest
----, cvp.cvp_highest
--
, coalesce(abg.abg_count,0) as abg_count
, coalesce(vbg.vbg_count,0) as vbg_count
, coalesce(abg.abg_count,0)+coalesce(vbg.vbg_count,0) as bg_total
, hct.hct_med
, hct.hct_lowest
, hct.hct_highest
, hct.hct_abnormal_flg


, wbc.wbc_first
, hgb.hgb_first
, platelet.platelet_first
, sodium.sodium_first
, potassium.potassium_first
, tco2.tco2_first
, chloride.chloride_first
, bun.bun_first
, creatinine.creatinine_first
, glucose.glucose_first
, calcium.calcium_first
, magnesium.magnesium_first
, phosphate.phosphate_first
, AST.AST_first
, ALT.ALT_first
, LDH.LDH_first
, bilirubin.bilirubin_first
, ALP.ALP_first
, albumin.albumin_first
, troponin_t.troponin_t_first
, CK.CK_first
, BNP.BNP_first
, lactate.lactate_first
, ph.ph_first
, svo2.svo2_first
, po2.po2_first
, pco2.pco2_first


--, wbc.wbc_first
--, coalesce(wbc.wbc_first,0) as wbc_first_coded
----, wbc.wbc_lowest
----, wbc.wbc_highest
--, wbc.wbc_abnormal_flg
--, hgb.hgb_first
--, coalesce(hgb.hgb_first, 0) as hgb_first_coded
----, hgb.hgb_lowest
----, hgb.hgb_highest
--, hgb.hgb_abnormal_flg
--, platelet.platelet_first
--, coalesce(platelet.platelet_first, 0) as platelet_first_coded
----, platelet.platelet_lowest
----, platelet.platelet_highest
--, platelet.platelet_abnormal_flg
--, sodium.sodium_first
--, coalesce(sodium.sodium_first, 0) as sodium_first_coded
----, sodium.sodium_lowest
----, sodium.sodium_highest
--, sodium.sodium_abnormal_flg
--, potassium.potassium_first
--, coalesce(potassium.potassium_first, 0) as potassium_first_coded
----, potassium.potassium_lowest
----, potassium.potassium_highest
--, potassium.potassium_abnormal_flg
--, tco2.tco2_first
--, coalesce(tco2.tco2_first, 0) as tco2_first_coded
----, tco2.tco2_lowest
----, tco2.tco2_highest
--, tco2.tco2_abnormal_flg
--, chloride.chloride_first
--, coalesce(chloride.chloride_first, 0) as chloride_first_coded
----, chloride.chloride_lowest
----, chloride.chloride_highest
--, chloride.chloride_abnormal_flg
--, bun.bun_first
--, coalesce(bun.bun_first, 0) as bun_first_coded
----, bun.bun_lowest
----, bun.bun_highest
--, bun.bun_abnormal_flg
--, creatinine.creatinine_first
--, coalesce(creatinine.creatinine_first, 0) as creatinine_first_coded
----, creatinine.creatinine_lowest
----, creatinine.creatinine_highest
--, creatinine.creatinine_abnormal_flg
--, po2.po2_first
--, coalesce(po2.po2_first, 0) as po2_first_coded
----, po2.po2_lowest
----, po2.po2_highest
--, po2.po2_abnormal_flg
--, pco2.pco2_first
--, coalesce(pco2.pco2_first, 0) as pco2_first_coded
----, pco2.pco2_lowest
----, pco2.pco2_highest
--, pco2.pco2_abnormal_flg
--
--
--, coalesce(res.flg,0) as restraint_flg
--
, fluid.fluid_day_1
, fluid.fluid_day_2
, fluid.fluid_day_3
, fluid.fluid_3days_raw
, fluid.fluid_3days_clean
, IV.IV_day_1
, IV.IV_day_2
, IV.IV_day_3
, IV.IV_3days_raw
, IV.IV_3days_clean
, rbc1.rbc_day_1
, rbct.rbc_total

, coalesce(da.flg,0) as dnr_adm_flg
, coalesce(ds.flg,0) as dnr_switch_flg
, coalesce(cs.flg,0) as cmo_switch_flg
, coalesce(dcs.flg,0) as dnr_cmo_switch_flg

, case when dur.aline_duration is null then 0
      when dur.aline_duration >1 then 1 else
       dur.aline_duration end as aline_duration

, 1 as dummy


from population pop
left join vent_group vent on vent.icustay_id=pop.icustay_id
--left join vent_12hr_group vent12 on vent12.icustay_id=pop.icustay_id
left join vaso_group vaso on vaso.icustay_id=pop.icustay_id
--left join vaso_12hr_group vaso12 on vaso12.icustay_id=pop.icustay_id
left join anes_group anes on anes.icustay_id=pop.icustay_id
--left join anes_12hr_group anes12 on anes12.icustay_id=pop.icustay_id
left join sedative_drug sed on sed.icustay_id=pop.icustay_id

left join sepsis_group sep on sep.hadm_id=pop.hadm_id
left join chf_group chf on chf.hadm_id=pop.hadm_id
left join afib_group afib on afib.hadm_id=pop.hadm_id
left join renal_group renal on renal.hadm_id=pop.hadm_id
left join liver_group liver on liver.hadm_id=pop.hadm_id
left join copd_group copd on copd.hadm_id=pop.hadm_id
left join cad_group cad on cad.hadm_id=pop.hadm_id
left join stroke_group stroke on stroke.hadm_id=pop.hadm_id
left join malignancy_group mal on mal.hadm_id=pop.hadm_id
left join resp_failure_group resp on resp.hadm_id=pop.hadm_id
left join ards_group ards on ards.hadm_id=pop.hadm_id
left join pneumonia_group pne on pne.hadm_id=pop.hadm_id


--
left join map_group m on m.icustay_id=pop.icustay_id
left join hr_group hr on hr.icustay_id=pop.icustay_id
left join t_group t on t.icustay_id=pop.icustay_id
left join spo2_group spo2 on spo2.icustay_id=pop.icustay_id
left join cvp_group cvp on cvp.icustay_id=pop.icustay_id

left join abg_count abg on abg.icustay_id=pop.icustay_id
left join vbg_count vbg on vbg.icustay_id=pop.icustay_id
left join lab_hct hct on hct.icustay_id=pop.icustay_id

left join lab_wbc wbc on wbc.icustay_id=pop.icustay_id
left join lab_hgb hgb on hgb.icustay_id=pop.icustay_id
left join lab_platelet platelet on platelet.icustay_id=pop.icustay_id
left join lab_sodium sodium on sodium.icustay_id=pop.icustay_id
left join lab_potassium potassium on potassium.icustay_id=pop.icustay_id
left join lab_tco2 tco2 on tco2.icustay_id=pop.icustay_id
left join lab_chloride chloride on chloride.icustay_id=pop.icustay_id
left join lab_bun bun on bun.icustay_id=pop.icustay_id
left join lab_creatinine creatinine on creatinine.icustay_id=pop.icustay_id
left join lab_glucose glucose on glucose.icustay_id=pop.icustay_id
left join lab_calcium calcium on calcium.icustay_id=pop.icustay_id
left join lab_magnesium magnesium on magnesium.icustay_id=pop.icustay_id
left join lab_phosphate phosphate on phosphate.icustay_id=pop.icustay_id
left join lab_AST AST on AST.icustay_id=pop.icustay_id
left join lab_ALT ALT on ALT.icustay_id=pop.icustay_id
left join lab_LDH LDH on LDH.icustay_id=pop.icustay_id
left join lab_bilirubin bilirubin on bilirubin.icustay_id=pop.icustay_id
left join lab_ALP ALP on ALP.icustay_id=pop.icustay_id
left join lab_albumin albumin on albumin.icustay_id=pop.icustay_id
left join lab_troponin_t troponin_t on troponin_t.icustay_id=pop.icustay_id
left join lab_CK CK on CK.icustay_id=pop.icustay_id
left join lab_BNP BNP on BNP.icustay_id=pop.icustay_id
left join lab_lactate lactate on lactate.icustay_id=pop.icustay_id
left join lab_ph ph on ph.icustay_id=pop.icustay_id
left join lab_svo2 svo2 on svo2.icustay_id=pop.icustay_id
left join lab_po2 po2 on po2.icustay_id=pop.icustay_id
left join lab_pco2 pco2 on pco2.icustay_id=pop.icustay_id


--
--
--left join restraint_group res on res.icustay_id=pop.icustay_id
--
left join fluid_in fluid on fluid.icustay_id=pop.icustay_id
left join IV_in IV on IV.icustay_id=pop.icustay_id
left join rbc_day_1 rbc1 on rbc1.icustay_id=pop.icustay_id
left join rbc_total rbct on rbct.icustay_id=pop.icustay_id

left join dnr_adm da on da.icustay_id=pop.icustay_id
left join dnr_switch ds on ds.icustay_id=pop.icustay_id
left join cmo_switch cs on cs.icustay_id=pop.icustay_id
left join dnr_cmo_switch dcs on dcs.icustay_id=pop.icustay_id

left join aline_duration dur on dur.icustay_id=pop.icustay_id

)

select * from aline_data;


--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- Clean version of the data -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
  
create table aline_cohort_data_june15 as
select a.*, coalesce(m.treated, -1) as matched_flg from aline_mimic_data_april15 a
left join aline_match m on m.icustay_id=a.icustay_id
where initial_aline_flg=0
and vent_1st_24hr=1
and sepsis_flg=0
and vaso_flg=0
and service_num<=1;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-------------------------- PS score matching  -------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------








