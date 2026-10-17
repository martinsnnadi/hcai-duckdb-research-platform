# Fixed-Width Splicing Loader Engine for NHANES III Survey Cycles
import duckdb
import os

DB_PATH = "data/unified_warehouse.db"
NHANES_DIR = "data/raw/nhanes3/"

def stream_file_to_staging(file_name, table_name):
    target_path = os.path.join(NHANES_DIR, file_name)
    if not os.path.exists(target_path):
        print(f"⚠ Warning: Source file missing at {target_path}, skipping loading cell.")
        return

    con = duckdb.connect(DB_PATH)
    con.execute(f"CREATE OR REPLACE TABLE staging.{table_name} (raw_record VARCHAR);")
    
    print(f"⏳ Streaming {file_name} characters line-by-line into staging.{table_name}...")
    
    with open(target_path, 'r', encoding='utf-8', errors='ignore') as f:
        chunk = []
        for line in f:
            # Strip carriage returns to eliminate unprintable ASCII/BOM parsing bugs
            chunk.append((line.rstrip('\r\n'),))
            if len(chunk) >= 25000:
                con.executemany(f"INSERT INTO staging.{table_name} VALUES (?);", chunk)
                chunk = []
        if chunk:
            con.executemany(f"INSERT INTO staging.{table_name} VALUES (?);", chunk)
            
    total_rows = con.execute(f"SELECT COUNT(*) FROM staging.{table_name};").fetchone()[0]
    print(f"✔ SUCCESS: Ingested {total_rows} lines into staging.{table_name}.")
    con.close()

if __name__ == "__main__":
    stream_file_to_staging("adult.dat", "raw_adult_holding")
    stream_file_to_staging("adultx.dat", "raw_adultx_holding")
    stream_file_to_staging("lab2.dat", "raw_lab_holding")
