-- dbt Silver Model: Telemetry Signal Processing and Experimental Noise Filtering
{{ config(materialized='table', schema='silver') }}

with raw_telemetry as (
    select * from {{ source('local_raw_source_files', 'raw_wesad_telemetry') }}
)
select
    subject_id,
    cast(affect_label as integer) as affect_label,
    cast(relative_timestamp as float) as relative_timestamp,
    cast(heart_rate as float) as heart_rate,
    cast(skin_temp as float) as skin_temp,
    cast(eda_level as float) as eda_level,
    current_timestamp as silver_processed_ts
from raw_telemetry
-- DATA CLEANING GATE 3: Strip out unmeasured experimental ambient noise (keep 1=Rest, 2=Stress, 3=Amusement)
where affect_label in (1, 2, 3)
