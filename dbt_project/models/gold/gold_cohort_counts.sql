-- System Verification Audit Ledger
select 'GOLD_OULAD_WEEKLY_ACTIVITY' as table_name, count(*) as record_count from {{ ref('gold_oulad_weekly_activity') }}
union all
select 'GOLD_NHANES3_PARTICIPANT_PROFILE' as table_name, count(*) as record_count from {{ ref('gold_nhanes3_participant_profile') }}
union all
select 'GOLD_WESAD_CONDITION_FEATURES' as table_name, count(*) as record_count from {{ ref('gold_wesad_condition_features') }}
