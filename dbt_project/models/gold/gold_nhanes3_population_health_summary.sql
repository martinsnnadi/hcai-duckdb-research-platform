{{ config(materialized='table', schema='gold') }}
select
    case when interview_age < 40 then 'Young Adult' when interview_age < 65 then 'Middle Aged' else 'Senior' end as age_group,
    case race_ethnicity_code when 1 then 'White' when 2 then 'Black' when 3 then 'Mexican American' else 'Other' end as race_ethnicity,
    avg(poverty_income_ratio) as average_poverty_ratio,
    avg(vitamin_d_level) as average_vitamin_d,
    avg(thyroid_stimulating_hormone) as average_tsh
from {{ ref('silver_nhanes3_adult_merged') }}
group by 1, 2
