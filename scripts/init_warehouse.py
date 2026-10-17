# Unified Open-Source Local Warehouse Schema Setup Engine
import duckdb
import os

DB_PATH = "data/unified_warehouse.db"

def init_db():
    print(f"⏳ Creating serverless local DuckDB file instance at: {DB_PATH}")
    # DuckDB creates the physical analytical database file natively on connection
    con = duckdb.connect(DB_PATH)
    
    # Establish our multi-tier schema pipeline layout
    con.execute("CREATE SCHEMA IF NOT EXISTS staging;")
    con.execute("CREATE SCHEMA IF NOT EXISTS silver;")
    con.execute("CREATE SCHEMA IF NOT EXISTS gold;")
    
    print("✔ Platform initialization complete. Schemas (staging, silver, gold) verified.")
    con.close()

if __name__ == "__main__":
    init_db()
