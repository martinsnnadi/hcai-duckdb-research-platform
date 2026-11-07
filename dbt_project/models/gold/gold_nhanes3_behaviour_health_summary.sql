{{ config(materialized='table', schema='gold') }}
select
    case when cotinine_level >= 15.0 then 'Smoker' else 'Non-Smoker' end as smoking_status,
    case when activity_metabolic_equivalent > 0 then 'Active' else 'Sedentary' end as activity_status,
    avg(thyroid_stimulating_hormone) as average_tsh,
    count(*) as record_count
from {{ ref('silver_nhanes3_adult_merged') }}
group by 1, 2
