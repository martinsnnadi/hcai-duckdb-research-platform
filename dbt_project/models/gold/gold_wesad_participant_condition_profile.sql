-- dbt Gold Model: Wearable Condition Profile with Integrated HITL Feedback Loop
{{ config(materialized='table', schema='gold') }}

with base_stream as (
    select * from {{ ref('silver_wesad_sessions') }}
),
resting as (
    select subject_id, avg(eda_level) as r_mean, stddev(eda_level) as r_std 
    from base_stream where affect_label = 1 group by 1
),
-- READ ACTIVE HUMAN VERDICTS FROM THE STAGING VIEW
human_feedback as (
    select subject_id, affect_label from {{ ref('stg_feedback__wesad_cured') }}
    where reviewer_decision = 'REJECTED_DROP'
),
calculated_profile as (
    select
        s.subject_id, s.affect_label, avg(s.heart_rate) as average_heart_rate, avg(s.skin_temp) as average_skin_temperature,
        avg(case when r.r_std > 0 then (s.eda_level - r.r_mean) / r.r_std else 0.0 end) as average_stress_velocity
    from base_stream s join resting r on s.subject_id = r.subject_id
    group by 1, 2
)
select p.*, current_timestamp as gold_processed_ts
from calculated_profile p
-- DATA GOVERNANCE FILTER: Excludes rows rejected by human judgement
where not exists (
    select 1 from human_feedback f 
    where p.subject_id = f.subject_id and p.affect_label = f.affect_label
)
