create table aline_mimic_cohort_feb14 as
with population as
(select subject_id, hadm_id, icustay_id, icustay_intime
from mimic2v26.icustay_detail
where SUBJECT_ICUSTAY_SEQ=1 
  and ICUSTAY_AGE_GROUP='adult'
  and hadm_id is not null
)

 --select * from population;
--select count(distinct icustay_id) from population; --23455

--, invasivemeanbp as
--(select distinct icud.icustay_id
----, ch.charttime
----, icud.icustay_intime
--from population p 
--join mimic2v26.icustay_detail icud on icud.icustay_id=p.icustay_id
--join mimic2v26.chartevents ch 
--  on p.icustay_id=ch.icustay_id 
--  --and ch.itemid in (select itemid from d_artlineitems where type=2 and itemid<>51)
--  and ch.itemid=52
--  and ch.value1num is not null
--  and ch.charttime<=icud.icustay_intime+1/24 
--)
--
----select * from invasivemeanbp; --4715 --4707
--
--, invasivebp as
--(select distinct icud.icustay_id
----, ch.charttime
----, icud.icustay_intime
--from population p
--join mimic2v26.icustay_detail icud on p.icustay_id=icud.icustay_id
--join mimic2v26.chartevents ch 
--  on p.icustay_id=ch.icustay_id 
--  and ch.itemid=51
--  and (ch.value1num is not null or ch.value2num is not null)
--  and ch.charttime<=icud.icustay_intime+1/24 
--)
--
----select * from invasivebp;
--
--, initial_aline as
--(select icustay_id, 1 as flg from invasivemeanbp
--union
--select icustay_id, 1 as flg from invasivebp
--)

--select * from initial_aline; --3910


----------------- Aline patients ------------------------
--, invasivemeanbp_all as
--(select distinct p.icustay_id
----, ch.charttime
----, icud.icustay_intime
--from  population p
--join mimic2v26.chartevents ch 
--  on p.icustay_id=ch.icustay_id 
--  --and ch.itemid in (select itemid from d_artlineitems where type=2 and itemid<>51)
--  and ch.itemid=52
--  and ch.value1num is not null 
--)

--select * from invasivemeanbp_all; --17048

, invasivebp_all as
(select distinct p.icustay_id
, first_value(ch.charttime) over (partition by p.icustay_id order by ch.charttime asc) as aline_time
--, ch.charttime
, p.icustay_intime
from population p
join mimic2v26.chartevents ch 
  on p.icustay_id=ch.icustay_id 
  and ch.itemid in (51,52)
  and (ch.value1num is not null or ch.value2num is not null)
--order by 1
)

--select * from invasivebp_all; --17104

, aline as
(select icustay_id
--, aline_time-icustay_intime as time_diff
, round((extract(day from aline_time-icustay_intime)
+extract(hour from aline_time-icustay_intime)/24
+extract(minute from aline_time-icustay_intime)/24/60),3) as  aline_time_day
, 1 as flg
from invasivebp_all
order by 3 asc
)

--select * from aline; --13416

, cohort as
(select p.*
, case when a.flg =1 and a.aline_time_day<=1/24 then 1 else 0 end as initial_aline_flg
, coalesce(a.flg,0) as aline_flg
, a.aline_time_day
from population p
--left join initial_aline i on p.icustay_id=i.icustay_id
left join aline a on p.icustay_id=a.icustay_id
)

select * from cohort;
--select count(distinct icustay_id) from cohort;
--select count(*) from cohort where initial_aline_flg=1; --6676