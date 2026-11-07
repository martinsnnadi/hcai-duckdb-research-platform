-- dbt Staging View: Reading Wearable Review Sheets Directly from Hard Drive
{{ config(materialized='view', schema='staging') }}

select
    subject_id,
    cast(affect_label as integer) as affect_label,
    coalesce(reviewer_decision, 'PENDING') as reviewer_decision
from read_csv_auto('../data/review/wesad_hardware_dropout_review.csv', normalize_names=True)
