# Martins Ifeanyi Nnadi - Month 2 Bronze Validation Inspector
import duckdb
import os

DB_PATH = "data/unified_warehouse.db"

if not os.path.exists(DB_PATH):
    print(f"❌ Error: Database file not found at {DB_PATH}. Run 'python scripts/init_warehouse.py' first.")
    exit(1)

try:
    # Connect in read-only mode to prevent database file locking conflicts
    con = duckdb.connect(DB_PATH, read_only=True)
    
    print("=======================================================================")
    print("📊 UNIFIED LOCAL PLATFORM - MONTH 2 BRONZE RECORDS SCORECARD")
    print("=======================================================================\n")
    
    # Check Track 1: OULAD Staging Tables
    print("📘 Track 1: OULAD Education Staging:")
    for tbl in ["raw_student_info", "raw_student_vle", "raw_assessments", "raw_student_assessment"]:
        try:
            count = con.execute(f"SELECT COUNT(*) FROM staging.{tbl};").fetchone()[0]
            print(f"  • staging.{tbl:<25} --> {count:,} rows conformed.")
        except Exception:
            print(f"  • staging.{tbl:<25} --> ❌ Empty / Not Loaded")

    # Check Track 2: NHANES Raw Text Staging Tables
    print("\n🔬 Track 2: NHANES III Survey Staging:")
    for tbl in ["raw_adult_holding", "raw_adultx_holding", "raw_lab_holding"]:
        try:
            count = con.execute(f"SELECT COUNT(*) FROM staging.{tbl};").fetchone()[0]
            print(f"  • staging.{tbl:<25} --> {count:,} raw lines loaded.")
        except Exception:
            print(f"  • staging.{tbl:<25} --> ❌ Empty / Not Loaded")

    # Check Track 3: WESAD Resampled Biometric Staging Table
    print("\n⌚ Track 3: WESAD Wearable Staging:")
    try:
        wesad_rows = con.execute("SELECT COUNT(*) FROM staging.raw_wesad_telemetry;").fetchone()[0]
        print(f"  • staging.raw_wesad_telemetry       --> {wesad_rows:,} conformed 1Hz rows.")
    except Exception:
        print("  • staging.raw_wesad_telemetry       --> ❌ Empty / Not Loaded")
        
    con.close()
    print("\n=======================================================================")
    print("🏁 Validation checklist iteration complete.")
    print("=======================================================================")
    
except Exception as e:
    print(f"❌ Connection Blocked: {str(e)}")
