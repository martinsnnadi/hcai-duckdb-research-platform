{{ config(materialized='table', schema='gold') }}
select
    case race_ethnicity_code when 1 then 'White' when 2 then 'Black' when 3 then 'Mexican American' else 'Other' end as race_ethnicity,
    count(*) as total_records,
    count(case when poverty_income_ratio is null then 1 end) * 100.0 / count(*) as missing_poverty_pct,
    count(case when thyroid_stimulating_hormone is null then 1 end) * 100.0 / count(*) as missing_tsh_pct
from {{ ref('silver_nhanes3_adult_merged') }}
group by 1
