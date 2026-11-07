-- dbt Staging View: Reading Education Review Sheets Directly from Hard Drive
{{ config(materialized='view', schema='staging') }}

select
    cast(student_id as varchar) as student_id,
    course_code,
    term_code,
    coalesce(reviewer_decision, 'PENDING') as reviewer_decision
from read_csv_auto('../data/review/oulad_demographic_fairness_review.csv', normalize_names=True)
