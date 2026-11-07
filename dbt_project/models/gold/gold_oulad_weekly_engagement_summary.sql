{{ config(materialized='table', schema='gold') }}
select
    code_module as course_code, code_presentation as term_code,
    floor(cast(date as integer) / 7) as study_week,
    count(distinct cast(id_student as varchar)) as active_students_count,
    sum(cast(sum_click as integer)) as total_clicks,
    avg(cast(sum_click as float)) as average_clicks_per_interaction
from {{ source('local_raw_source_files', 'raw_student_vle') }}
group by 1, 2, 3
