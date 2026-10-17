-- Enforces Section 4 privacy boundaries via salted cryptographic hashes
with silver_source as (
    select * from {{ ref('silver_nhanes3_adult_merged') }}
)
select
    -- Generates irreversible surrogate keys to protect participant IDs (RQ-H1c)
    sha256(concat(cast(participant_seqn as varchar), 'SALT_HCAI_2026')) as participant_surrogate_key,
    interview_age as interview_age_years,
    poverty_income_ratio,
    activity_metabolic_equivalent,
    case race_ethnicity_code when 1 then 'White' when 2 then 'Black' when 3 then 'Mexican American' else 'Other' end as race_ethnicity,
    -- Binarizes raw biomarker features into explainable clinical practice metrics
    case when cotinine_level >= 15.0 then 1 else 0 end as is_active_smoker,
    case when vitamin_d_level < 20.0 then 1 else 0 end as is_vitamin_d_deficient,
    current_timestamp as gold_processed_ts
from silver_source
