-- dbt Staging View: Parsing Fixed-Width Extended Survey Responses
{{ config(materialized='view', schema='staging') }}

with raw_adultx_source as (
    select raw_record from {{ source('local_raw_source_files', 'raw_adultx_holding') }}
)
select
    try_cast(substring(raw_record, 1, 5) as integer) as participant_seqn,
    -- Extracts physical context columns from precise byte coordinates
    try_cast(substring(raw_record, 42, 4) as float) as activity_metabolic_equivalent
from raw_adultx_source
where participant_seqn is not null
