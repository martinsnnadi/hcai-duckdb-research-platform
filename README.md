# Human-Centred Research Data Platform

A 100% free, local-first open-source data engineering platform designed to ingest, cleanse, and harmonize heterogeneous streams across education, epidemiology, and wearable computing domains using DuckDB and dbt Core.

## 🏛️ Platform Architecture
- **Ingestion & Infrastructure Layer:** Python file-streaming buffers and binary pickle loaders.
- **Relational Compute Engine:** Serverless in-process DuckDB columnar database instance.
- **Data Pipeline Orchestrator:** dbt Core managing Staging, Silver, and Gold transformations.
- **Reporting Analytics Tier:** Power BI Desktop local data connections.

## 📊 Milestone Tracks
- **Track 1 (Education / OULAD):** Transforming 10.6M rows of clickstream records into longitudinal weekly engagement matrices.
- **Track 2 (Epidemiology / NHANES III):** Automated fixed-width byte-slicing and multi-way inner joins combining standard adult demographics, extended surveys (`adultx`), and chemical lab biomarkers. Implements explicit data governance outlier sanitization gates.
- **Track 3 (Wearables / WESAD):** Unpacking multi-sensor high-frequency physiological streams across 15 separate participant cohorts into unified 1Hz tracking profiles.

## 🚀 Local Build Instructions
```bash
# 1. Install project dependencies
pip install -r requirements.txt

# 2. Run Python raw ingestion loaders
python scripts/init_warehouse.py
python scripts/load_nhanes3.py
python scripts/load_oulad.py
python scripts/load_wesad.py

# 3. Compile and test the data warehouse pipelines
cd dbt_project
dbt deps
dbt run
dbt test
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
│   └── 📁 review/               ◄── Isolated path for anomaly review logs
│
```

### 🔧 Verifying Your Local Path Configuration
Before running scripts, ensure your working directory paths match your user profile by updating `dbt_project/profiles.yml`. Change the absolute database path to point exactly to your disk drive location.
