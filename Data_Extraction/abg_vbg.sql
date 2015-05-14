--create table aline_abg_vbg as
with population as
(select * from mornin.ALINE_MATCH
--where icustay_id<10
--where initial_aline_flg = 0
)

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

,abg_lab as(
select distinct 
pop.icustay_id
, ch.charttime
, count(*) as labcount
from population pop
join mimic2v26.chartevents ch on ch.icustay_id=pop.icustay_id
  and ch.itemid in (778,779, 780) and ch.value1 is not null
group by pop.icustay_id, ch.charttime
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

--abg 778,779, 780
, treated as
(select m.icustay_id
, m.n1
, coalesce(a.abg_count,0) as abg_count_t
, coalesce(v.vbg_count,0) as vbg_count_t
from mornin.aline_match m
left join abg_count a on m.icustay_id=a.icustay_id
left join vbg_count v on m.icustay_id=v.icustay_id
where m.treated=1
)

--select * from treated;

, untreated as
(select m.icustay_id
, m.id
, coalesce(a.abg_count,0) as abg_count_u
, coalesce(v.vbg_count,0) as vbg_count_u
from mornin.aline_match m
left join abg_count a on m.icustay_id=a.icustay_id
left join vbg_count v on m.icustay_id=v.icustay_id
where m.treated=0
)

--select * from untreated;
, final_table_1 as
(select t.*
, u.abg_count_u
, u.vbg_count_u
from treated t
join untreated u on t.n1=u.id
)

--select * from final_table_1;
, final_table as
(select f.*
, p.ICU_LOS_DAY_T
, p.ICU_LOS_DAY_u
, round(f.abg_count_t/p.ICU_LOS_DAY_T,2) as abg_count_norm_t
, round(f.vbg_count_t/p.ICU_LOS_DAY_T,2) as vbg_count_norm_t
, round(f.abg_count_u/p.ICU_LOS_DAY_U,2) as abg_count_norm_u
, round(f.vbg_count_u/p.ICU_LOS_DAY_U,2) as vbg_count_norm_u
from final_table_1 f
join mornin.ALINE_PAIRED_DATA_MAY15 p on f.icustay_id=p.icustay_id_t
)

select * from final_table;