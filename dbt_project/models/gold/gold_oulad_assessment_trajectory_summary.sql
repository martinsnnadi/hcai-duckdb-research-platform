-- dbt Gold Model: Assessment Trajectory Summary with Safe Type Casting Override
{{ config(materialized='table', schema='gold') }}

select
    a.id_assessment as assessment_id, 
    a.assessment_type,
    s.final_result as student_outcome_group,
    count(distinct cast(sa.id_student as varchar)) as participating_students,
    
    -- FIXED: Using try_cast instead of cast to safely turn non-numeric strings ("?") into NULL parameters
    avg(try_cast(sa.score as float)) as average_score,
    avg(try_cast(sa.date_submitted as integer) - try_cast(a.date as integer)) as average_days_relative_to_deadline

from {{ source('local_raw_source_files', 'raw_assessments') }} a
join {{ source('local_raw_source_files', 'raw_student_assessment') }} sa on a.id_assessment = sa.id_assessment
join {{ source('local_raw_source_files', 'raw_student_info') }} s on sa.id_student = s.id_student 
                                                                 and a.code_module = s.code_module 
                                                                 and a.code_presentation = s.code_presentation
group by 1, 2, 3
