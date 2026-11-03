# Martins Ifeanyi Nnadi - Month 5: Multi-Track Human-in-the-Loop Curation Engine
import duckdb
import os
import pandas as pd

DB_PATH = "data/unified_warehouse.db"
REVIEW_DIR = "data/review/"

def execute_complete_hitl_curation_gate():
    print("⏳ Launching Month 5 Unified Multi-Track Hybrid Intelligence Scan...")
    
    if not os.path.exists(DB_PATH):
        print(f"❌ Error: Database file not found at {DB_PATH}. Run your dbt pipeline first.")
        return

    os.makedirs(REVIEW_DIR, exist_ok=True)
    con = duckdb.connect(DB_PATH)
    
    # Initialize an immutable global data curation audit log ledger (RQ-W1d / RQ-H2)
    con.execute("""
        CREATE TABLE IF NOT EXISTS gold.gold_curation_audit (
            track_name VARCHAR,
            entity_id VARCHAR,
            anomaly_reason VARCHAR,
            flagged_timestamp TIMESTAMP
        );
    """)
    
    # =========================================================================
    # GATE 1: OULAD Demographic Fairness Review (RQ-E1c)
    # =========================================================================
    print("⏳ Auditing Track 1 (OULAD) for fairness and missing demographic bands...")
    df_oulad_flags = con.execute("""
        SELECT student_id, course_code, term_code, deprivation_band_pct
        FROM silver.silver_oulad_students
        WHERE deprivation_band_pct IS NULL OR deprivation_band_pct = '';
    """).df()
    
    if not df_oulad_flags.empty:
        df_oulad_flags.to_csv(os.path.join(REVIEW_DIR, "oulad_demographic_fairness_review.csv"), index=False)
        for _, row in df_oulad_flags.iterrows():
            con.execute("INSERT INTO gold.gold_curation_audit VALUES ('OULAD', ?, 'Missing deprivation band index detected', CURRENT_TIMESTAMP);", (row['student_id'],))
        print(f"  ⚠ Flagged {len(df_oulad_flags)} student profiles for demographic fairness audit.")
    else:
        print("  ✔ Track 1 demographic layers are clean.")

    # =========================================================================
    # GATE 2: NHANES Clinical Anomaly Review (RQ-H2)
    # =========================================================================
    print("⏳ Auditing Track 2 (NHANES) for rare medical phenotypes...")
    df_nhanes_flags = con.execute("""
        SELECT participant_seqn, interview_age, thyroid_stimulating_hormone
        FROM silver.silver_nhanes3_adult_merged
        WHERE thyroid_stimulating_hormone >= 10.0;
    """).df()
    
    if not df_nhanes_flags.empty:
        df_nhanes_flags.to_csv(os.path.join(REVIEW_DIR, "nhanes_clinical_anomaly_review.csv"), index=False)
        for _, row in df_nhanes_flags.iterrows():
            con.execute("INSERT INTO gold.gold_curation_audit VALUES ('NHANES', ?, 'Extreme clinical TSH baseline spike detected', CURRENT_TIMESTAMP);", (str(row['participant_seqn']),))
        print(f"  ⚠ Isolated {len(df_nhanes_flags)} records for clinical expert validation.")
    else:
        print("  ✔ Track 2 clinical indicators are clean.")

    # =========================================================================
    # GATE 3: WESAD Sensor Uncertainty Review (RQ-W1d)
    # =========================================================================
    print("⏳ Auditing Track 3 (WESAD) for physical hardware telemetry dropouts...")
    df_wesad_flags = con.execute("""
        SELECT subject_id, affect_label, average_heart_rate, average_stress_velocity
        FROM gold.gold_wesad_condition_features
        WHERE average_heart_rate > 150.0 OR average_stress_velocity > 4.5;
    """).df()
    
    if not df_wesad_flags.empty:
        df_wesad_flags.to_csv(os.path.join(REVIEW_DIR, "wesad_hardware_dropout_review.csv"), index=False)
        for _, row in df_wesad_flags.iterrows():
            con.execute("INSERT INTO gold.gold_curation_audit VALUES ('WESAD', ?, 'Extreme physiological sensor tracking noise detected', CURRENT_TIMESTAMP);", (row['subject_id'],))
        print(f"  ⚠ Isolated {len(df_wesad_flags)} sessions for physical telemetry audit.")
    else:
        print("  ✔ Track 3 physiological matrices are clean.")

    total_flags = len(df_oulad_flags) + len(df_nhanes_flags) + len(df_wesad_flags)
    print(f"\n🚀 SUCCESS: Unified curation complete. {total_flags} records isolated across your local drive.")
    con.close()

if __name__ == "__main__":
    execute_complete_hitl_curation_gate()
