-- dbt Silver Model: Outlier Cleansing and Intra-Cycle Multi-Source Harmonisation
{{ config(materialized='table', schema='silver') }}

with base_adult as (
    select * from {{ ref('stg_nhanes3__adult') }}
),
extended_adult as (
    select * from {{ ref('stg_nhanes3__adultx') }}
),
lab_biomarkers as (
    select * from {{ ref('stg_nhanes3__lab') }}
)
select
    a.participant_seqn,
    a.biological_sex_code,
    a.interview_age,
    a.race_ethnicity_code,
    
    -- DATA CLEANING GATE 1: Outlier Sanitisation to resolve system sentinels
    case when a.poverty_income_ratio >= 99.00 then null else a.poverty_income_ratio end as poverty_income_ratio,
    case when l.cotinine_level >= 8888.0 then null else l.cotinine_level end as cotinine_level,
    case when l.vitamin_d_level >= 9999.0 then null else l.vitamin_d_level end as vitamin_d_level,
    case when l.thyroid_stimulating_hormone >= 8888.0 then null else l.thyroid_stimulating_hormone end as thyroid_stimulating_hormone,
    
    ax.activity_metabolic_equivalent,
    current_timestamp as silver_processed_ts

from base_adult a
-- Relational Inner Joins handle the 11,152 unanchored record drops automatically
inner join extended_adult ax on a.participant_seqn = ax.participant_seqn
inner join lab_biomarkers l on a.participant_seqn = l.participant_seqn
