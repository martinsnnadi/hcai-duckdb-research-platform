{{ config(materialized='table', schema='gold') }}
select subject_id, affect_label, count(*) as total_session_seconds
from {{ ref('silver_wesad_sessions') }} group by 1, 2
