-- Longitudinal Variance Model (RQ-E1a)
with raw_vle_interactions as (
    select 
        cast(id_student as varchar) as student_id,
        code_module as course_code,
        code_presentation as term_code,
        cast(date as integer) as relative_interaction_day,
        cast(sum_click as integer) as daily_click_count
    from read_csv_auto('C:/Users/nnadi/data-engineering/wesad/human-centred-research-data-platform/data/raw/oulad/studentVle.csv', header=true)
),
scaled_study_weeks as (
    select
        student_id,
        course_code,
        term_code,
        -- Floor division dynamically standardizes daily interactions into study weeks
        floor(relative_interaction_day / 7) as study_week,
        daily_click_count
    from raw_vle_interactions
)
select
    course_code,
    term_code,
    study_week,
    count(distinct student_id) as active_students_count,
    sum(daily_click_count) as total_weekly_clicks,
    -- Longitudinal Variance tracks student interaction habits week-over-week
    stddev(daily_click_count) as weekly_click_variance,
    current_timestamp as gold_processed_ts
from scaled_study_weeks
group by course_code, term_code, study_week
