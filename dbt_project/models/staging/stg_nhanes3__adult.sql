-- dbt Staging View: Parsing Fixed-Width Demographic Records
{{ config(materialized='view', schema='staging') }}

with raw_adult_source as (
    select raw_record from {{ source('local_raw_source_files', 'raw_adult_holding') }}
)
select
    try_cast(substring(raw_record, 1, 5) as integer) as participant_seqn,
    try_cast(substring(raw_record, 12, 1) as integer) as race_ethnicity_code,
    try_cast(substring(raw_record, 15, 1) as integer) as biological_sex_code,
    try_cast(substring(raw_record, 18, 2) as integer) as interview_age,   
    try_cast(substring(raw_record, 36, 6) as float) as poverty_income_ratio
from raw_adult_source
where participant_seqn is not null
