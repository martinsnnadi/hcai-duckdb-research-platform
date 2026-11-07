{{ config(materialized='table', schema='gold') }}

with silver_data as (
    select * from {{ ref('silver_nhanes3_adult_merged') }}
),
human_feedback as (
    select participant_seqn from {{ ref('stg_feedback__nhanes_cured') }}
    where reviewer_decision = 'REJECTED_DROP'
)
select
    sha256(concat(cast(participant_seqn as varchar), 'SALT_2026')) as participant_surrogate_key,
    interview_age, poverty_income_ratio, activity_metabolic_equivalent,
    case race_ethnicity_code when 1 then 'White' when 2 then 'Black' when 3 then 'Mexican American' else 'Other' end as race_ethnicity,
    case when cotinine_level >= 15.0 then 1 else 0 end as is_active_smoker,
    case when vitamin_d_level < 20.0 then 1 else 0 end as is_vitamin_d_deficient,
    case when thyroid_stimulating_hormone >= 4.5 then 1 else 0 end as has_elevated_tsh
from silver_data
where participant_seqn not in (select participant_seqn from human_feedback)
