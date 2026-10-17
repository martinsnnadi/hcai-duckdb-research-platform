-- dbt Silver Model: Realignment Data Cleansing & Harmonisation Gate
{{ config(materialized='table', schema='silver') }}

with base_adult_stage as (
    select
        try_cast(substring(raw_record, 1, 5) as integer) as participant_seqn,
        try_cast(substring(raw_record, 12, 1) as integer) as race_ethnicity_code,
        try_cast(substring(raw_record, 15, 1) as integer) as biological_sex_code,
        try_cast(substring(raw_record, 18, 2) as integer) as interview_age,   
        -- Trim whitespace blocks before casting to prevent structural parsing drift
        try_cast(trim(substring(raw_record, 36, 6)) as float) as poverty_income_ratio
    from {{ source('local_raw_source_files', 'raw_adult_holding') }}
),

extended_adult_stage as (
    select * from {{ ref('stg_nhanes3__adultx') }}
),

lab_biomarkers_stage as (
    select
        try_cast(substring(raw_record, 1, 5) as integer) as participant_seqn,
        try_cast(trim(substring(raw_record, 1246, 4)) as float) as cotinine_level,
        try_cast(trim(substring(raw_record, 1255, 5)) as float) as vitamin_d_level,
        try_cast(trim(substring(raw_record, 1274, 5)) as float) as thyroid_stimulating_hormone
    from {{ source('local_raw_source_files', 'raw_lab_holding') }}
)

select
    a.participant_seqn,
    a.biological_sex_code,
    a.interview_age,
    a.race_ethnicity_code,
    
    -- DATA GOVERNANCE GATE 1: Outlier Sanitisation to resolve system sentinels
    case when a.poverty_income_ratio >= 99.00 or a.poverty_income_ratio < 0 then null else a.poverty_income_ratio end as poverty_income_ratio,
    case when l.cotinine_level >= 8888.0 then null else l.cotinine_level end as cotinine_level,
    case when l.vitamin_d_level >= 9999.0 then null else l.vitamin_d_level end as vitamin_d_level,
    case when l.thyroid_stimulating_hormone >= 8888.0 then null else l.thyroid_stimulating_hormone end as thyroid_stimulating_hormone,
    
    -- DATA GOVERNANCE GATE 2: Left Join protection ensures adultx files don't drop target rows from the 18,162 cohort
    coalesce(ax.activity_metabolic_equivalent, 0.0) as activity_metabolic_equivalent,
    current_timestamp as silver_processed_ts

from base_adult_stage a
inner join lab_biomarkers_stage l on a.participant_seqn = l.participant_seqn
left join extended_adult_stage ax on a.participant_seqn = ax.participant_seqn
where a.participant_seqn is not null
