{{ config(materialized='table', schema='gold') }}
with students as (select * from {{ ref('silver_oulad_students') }}),
clicks as (
    select cast(id_student as varchar) as student_id, sum(cast(sum_click as integer)) as total_clicks
    from {{ source('local_raw_source_files', 'raw_student_vle') }} group by 1
)
select s.*, coalesce(c.total_clicks, 0) as total_vle_clicks, current_timestamp as gold_ts
from students s left join clicks c on s.student_id = c.student_id
