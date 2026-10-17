-- Individualised Baseline Standardisation Engine (RQ-W2 Personalisation)
with raw_telemetry as (
    select 
        subject_id,
        cast(affect_label as integer) as affect_label,
        cast(relative_timestamp as float) as relative_timestamp,
        cast(heart_rate as float) as heart_rate,
        cast(skin_temp as float) as skin_temp,
        cast(eda_level as float) as eda_level
    -- DuckDB reads nested folders natively via wildcard path strings (*.csv)
    from read_csv_auto('C:/Users/nnadi/data-engineering/wesad/human-centred-research-data-platform/data/raw/wesad/*/*.csv', header=true)
),
subject_resting_baselines as (
    -- Extract resting control references (affect label 1) to derive subject constants
    select
        subject_id,
        avg(eda_level) as rest_eda_mean,
        stddev(eda_level) as rest_eda_std
    from raw_telemetry
    where affect_label = 1
    group by subject_id
),
z_score_transformed_stream as (
    select
        t.subject_id,
        t.affect_label,
        t.relative_timestamp,
        t.heart_rate,
        t.skin_temp,
        -- Z-Score calculation model neutralizes biological drift between distinct human bodies
        case 
            when b.rest_eda_std > 0 then (t.eda_level - b.rest_eda_mean) / b.rest_eda_std 
            else 0.0 
        end as standardized_eda_score
    from raw_telemetry t
    inner join subject_resting_baselines b on t.subject_id = b.subject_id
)
select
    subject_id,
    affect_label,
    count(relative_timestamp) as total_session_seconds,
    avg(standardized_eda_score) as average_stress_velocity,
    avg(heart_rate) as average_heart_rate,
    avg(skin_temp) as average_skin_temperature,
    current_timestamp as gold_processed_ts
from z_score_transformed_stream
group by subject_id, affect_label
