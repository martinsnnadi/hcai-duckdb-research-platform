{{ config(materialized='table', schema='gold') }}

with silver_data as (
    select * from {{ ref('silver_oulad_students') }}
),
human_feedback as (
    select student_id from {{ ref('stg_feedback__oulad_cured') }}
    where reviewer_decision = 'REJECTED_DROP'
)
select
    age_band, biological_sex, deprivation_band_pct, course_code, academic_outcome,
    count(*) as student_count, avg(studied_credits) as average_credits_studied
from silver_data
where student_id not in (select student_id from human_feedback)
group by 1, 2, 3, 4, 5
