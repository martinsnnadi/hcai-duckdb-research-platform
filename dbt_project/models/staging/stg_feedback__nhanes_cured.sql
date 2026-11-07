-- dbt Staging View: Reading Public Health Review Sheets Directly from Hard Drive
{{ config(materialized='view', schema='staging') }}

select
    cast(participant_seqn as integer) as participant_seqn,
    coalesce(reviewer_decision, 'PENDING') as reviewer_decision
from read_csv_auto('../data/review/nhanes_clinical_anomaly_review.csv', normalize_names=True)
