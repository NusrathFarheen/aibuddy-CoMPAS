import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "planner.db")

def migrate():
    print(f"Checking database at {DB_PATH}...")
    conn = sqlite3.connect(DB_PATH)
    try:
        cursor = conn.cursor()
        # Check if template_id exists
        cursor.execute("PRAGMA table_info(goals)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if "template_id" not in columns:
            print("Adding template_id column to goals table...")
            cursor.execute("ALTER TABLE goals ADD COLUMN template_id TEXT DEFAULT 'daily'")
            conn.commit()
            print("Migration successful!")
        else:
            print("template_id column already exists.")
            
    except Exception as e:
        print(f"Migration failed: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
