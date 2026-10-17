-- dbt Staging View: Parsing Fixed-Width Continuous Biomarkers
{{ config(materialized='view', schema='staging') }}

with raw_lab_source as (
    select raw_record from {{ source('local_raw_source_files', 'raw_lab_holding') }}
)
select
    try_cast(substring(raw_record, 1, 5) as integer) as participant_seqn,
    try_cast(substring(raw_record, 1246, 4) as float) as cotinine_level,
    try_cast(substring(raw_record, 1255, 5) as float) as vitamin_d_level,
    try_cast(substring(raw_record, 1274, 5) as float) as thyroid_stimulating_hormone
from raw_lab_source
where participant_seqn is not null
