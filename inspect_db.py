import sqlite3

conn = sqlite3.connect("planner.db")
cursor = conn.cursor()

# List all tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()
print("Tables:", [t[0] for t in tables])

for table in tables:
    name = table[0]
    print(f"\n--- {name} ---")
    cursor.execute(f"PRAGMA table_info({name})")
    for col in cursor.fetchall():
        print(f"  {col}")

conn.close()
