{{ config(materialized='table', schema='gold') }}
select
    subject_id, count(*) as total_logged_seconds,
    count(case when heart_rate <= 0 or heart_rate is null then 1 end) as invalid_hr_seconds,
    count(case when eda_level <= 0 or eda_level is null then 1 end) as invalid_eda_seconds
from {{ ref('silver_wesad_sessions') }} group by 1
