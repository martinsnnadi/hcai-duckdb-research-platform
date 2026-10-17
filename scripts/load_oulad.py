#Month 2: OULAD Bronze CSV Ingestion Engine
import duckdb
import os

DB_PATH = "data/unified_warehouse.db"
OULAD_DIR = "data/raw/oulad/"

def ingest_oulad_bronze():
    if not os.path.exists(OULAD_DIR):
        print(f"❌ Aborted: Target raw OULAD directory missing at {OULAD_DIR}")
        return

    con = duckdb.connect(DB_PATH)
    
    # Mapping of raw files to immutable staging holding tables
    oulad_files = {
        "studentInfo.csv": "raw_student_info",
        "studentVle.csv": "raw_student_vle",
        "assessments.csv": "raw_assessments",
        "studentAssessment.csv": "raw_student_assessment"
    }
    
    print("⏳ Loading OULAD CSV files into raw database landing tables...")
    for file_name, table_name in oulad_files.items():
        src_path = os.path.join(OULAD_DIR, file_name)
        if not os.path.exists(src_path):
            print(f"⚠ Warning: {file_name} missing from path. Skipping file.")
            continue
            
        con.execute(f"""
            CREATE OR REPLACE TABLE staging.{table_name} AS 
            SELECT * FROM read_csv_auto('{src_path}', header=True);
        """)
        row_count = con.execute(f"SELECT COUNT(*) FROM staging.{table_name};").fetchone()[0]
        print(f"✔ SUCCESS: Ingested {row_count:,} rows into staging.{table_name}")
        
    con.close()

if __name__ == "__main__":
    ingest_oulad_bronze()
