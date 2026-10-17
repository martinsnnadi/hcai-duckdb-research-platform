-- dbt Silver Model: Cleansing and Standardising OULAD Student Profiles
{{ config(materialized='table', schema='silver') }}

with raw_source as (
    select * from {{ source('local_raw_source_files', 'raw_student_info') }}
)
select
    cast(id_student as varchar) as student_id,
    code_module as course_code,
    code_presentation as term_code,
    gender as biological_sex,
    highest_education,
    
    -- DATA CLEANING GATE 1: Handle structural missingness anomalies in deprivation bands
    case 
        when imd_band is null or imd_band = '' or imd_band = '?' then null 
        else imd_band 
    end as deprivation_band_pct,
    
    age_band,
    num_of_prev_attempts as historical_attempts_count,
    studied_credits,
    disability as disability_status,
    final_result as academic_outcome,
    current_timestamp as silver_processed_ts
from raw_source
