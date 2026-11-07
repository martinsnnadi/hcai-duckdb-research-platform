{{ config(materialized='table', schema='gold') }}
select
    affect_label, avg(heart_rate) as group_mean_hr, stddev(heart_rate) as group_std_hr,
    avg(eda_level) as group_mean_eda, avg(skin_temp) as group_mean_temp
from {{ ref('silver_wesad_sessions') }} group by 1
