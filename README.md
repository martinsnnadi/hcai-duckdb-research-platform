# Human-Centred Research Data Platform

A 100% free, local-first open-source data engineering platform designed to ingest, cleanse, and harmonize heterogeneous streams across education, epidemiology, and wearable computing domains using DuckDB and dbt Core.

## 🏛️ Platform Architecture
- **Ingestion & Infrastructure Layer:** Python file-streaming buffers and binary pickle loaders.
- **Relational Compute Engine:** Serverless in-process DuckDB columnar database instance running locally on host RAM.
- **Data Pipeline Orchestrator:** dbt Core managing Staging, Silver, and Gold transformations.
- **Interactive Feedback Layer:** Native DuckDB `read_csv_auto` loops merging reviewer overrides.
- **Reporting Analytics Tier:** Power BI Desktop local data connections.

## 📊 Milestone Tracks & 12 Gold Production Marts

### 📘 Track 1: Education (OULAD) — Resolves RQ-E1 & RQ-E2
Ingests 10.6M raw student logs to construct explainable, non-predictive indicators for proactive educator intervention:
- `gold_oulad_student_module_summary`: Aggregated total clicks and module performance histories per student.
- `gold_oulad_weekly_engagement_summary`: Longitudinal time-series tracking student attendance and click variance blocks week-over-week.
- `gold_oulad_assessment_trajectory_summary`: Tracks submission pacing and score margins relative to dead-line milestones.
- `gold_oulad_student_group_outcome_summary`: Demographic performance matrices to audit for systemic education fairness gaps.

### 🔬 Track 2: Epidemiology (NHANES III) — Resolves RQ-H1 & RQ-H2
Applies byte-slicing and protective `LEFT JOIN` operations over demographics and lab data to isolate an absolute baseline of **18,162 clean health records** while maintaining Section 4 privacy parameters:
- `gold_nhanes3_participant_health_profile`: Anonymized research records utilizing salted SHA-256 cryptographic keys combined with binarized clinical phenotype flags.
- `gold_nhanes3_population_health_summary`: Baseline health indicator distributions across age cohorts and income blocks.
- `gold_nhanes3_behaviour_health_summary`: Correlates lifestyle habits (smoking, exercise) directly with metabolic risk data.
- `gold_nhanes3_health_data_quality_summary`: Tracks data missingness and collection imbalances across subgroups to expose sampling bias.

### ⌚ Track 3: Wearable Computing (WESAD) — Resolves RQ-W1 & RQ-W2
Unpacks multi-sensor physiological signal streams across 15 separate participant cohorts, downsampling binary pickle streams into unified 1Hz tracking profiles:
- `gold_wesad_participant_session_summary`: Active duration stopwatch logs across neutral, stress, and amusement conditions.
- `gold_wesad_sensor_condition_summary`: Group-level statistical baseline summaries for multi-modal physiological sensors.
- `gold_wesad_participant_condition_profile`: Individualized Z-score baseline normalization model isolating pure emotional state responses.
- `gold_wesad_sensor_quality_summary`: Diagnostic hardware log tracking sensor flatlines, invalid readouts, and wire contacts.

## 🤖 Month 5: Hybrid Intelligence & Human-in-the-Loop (HITL) Curation
The platform avoids blind automated data adjustments. An **Audit-After-Materialisation Gate** script (`curation.py`) scans finalized tables, flags rows breaching logical reference boundaries, logs exceptions inside `gold.gold_curation_audit`, and drops anomalies into separate spreadsheets under `data/review/`. 

Downstream Gold transformation models run an interactive feedback loop via an exclusion join. Reviewers update the `.csv` logs with a `REJECTED_DROP` verdict to filter out demographic fairness gaps, severe clinical outliers, and physical hardware sensor dropouts automatically upon the next dbt compilation.

## 🚀 Local Build Instructions

```bash
# 1. Install project dependencies
pip install -r requirements.txt

# 2. Run Python raw ingestion loaders (Bronze Tier)
python scripts/init_warehouse.py
python scripts/load_oulad.py
python scripts/load_nhanes3.py
python scripts/load_wesad.py

# 3. Execute the Human-in-the-Loop Exception Curation script
python scripts/curation.py

# 4. Compile and test the data warehouse feedback pipelines (Silver & Gold Tiers)
cd dbt_project
dbt deps
dbt run --select +models/gold/*
dbt test --select models/silver/*
```

## 📂 Local Data Directory & Placement Guide

To execute the ingestion scripts successfully, the raw, unzipped source datasets must be placed into the following exact filesystem paths relative to the project root:

```text
📁 human-centred-research-data-platform/
│
├── 📁 data/
│   ├── 📁 raw/
│   │   ├── 📁 oulad/            ◄── Place OULAD CSV files here
│   │   │   ├── studentInfo.csv
│   │   │   ├── studentVle.csv
│   │   │   ├── assessments.csv
│   │   │   └── studentAssessment.csv
│   │   │
│   │   ├── 📁 nhanes3/          ◄── Place NHANES III DAT files here
│   │   │   ├── adult.dat
│   │   │   ├── adultx.dat
│   │   │   └── lab2.dat
│   │   │
│   │   └── 📁 wesad/            ◄── Place unzipped WESAD Subject folders here
│   │       ├── 📁 S2/
│   │       │   └── S2.pkl
│   │       ├── 📁 S3/
│   │       │   └── S3.pkl
│   │       └── 📁 ... [S4 to S17]
│   │
│   ├── 📁 staged/               ◄── System internal temporary state folder
│   ├── 📁 exports/              ◄── Target folder for final CSV/Parquet outputs
│   └── 📁 review/               ◄── Isolated path for interactive HITL review sheets
│
```

## 🔧 Verifying Your Local Path Configuration
Before running pipelines, ensure your working directory paths match your user profile by updating `dbt_project/profiles.yml`. Change the absolute database path to point exactly to your disk drive location.
