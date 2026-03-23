"""
AIBuddy (CoM-PAS) — Database Layer
SQLite database connection, table creation, and CRUD helpers.
Schema matches the original planner.db exactly.
"""

import sqlite3
import os
from contextlib import contextmanager

# Database lives at project root (next to backend/)
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "planner.db")


@contextmanager
def get_db():
    """Context manager for database connections with row_factory."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def init_db():
    """Create all tables if they don't exist. Matches original planner.db schema."""
    with get_db() as conn:
        cursor = conn.cursor()

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS goals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                deadline TEXT,
                progress INTEGER DEFAULT 0,
                status TEXT DEFAULT 'active',
                is_pinned BOOLEAN DEFAULT 0,
                current_value INTEGER DEFAULT 0,
                target_value INTEGER DEFAULT 100,
                template_id TEXT DEFAULT 'daily',
                is_archived BOOLEAN DEFAULT 0,
                is_deleted BOOLEAN DEFAULT 0
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                goal_id INTEGER,
                description TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT 0,
                scheduled_date TEXT,
                last_completed TEXT,
                status TEXT DEFAULT 'todo',
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS routines (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT 0,
                category TEXT DEFAULT 'general',
                last_completed_date TEXT,
                current_streak INTEGER DEFAULT 0,
                best_streak INTEGER DEFAULT 0
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS journal_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                goal_id INTEGER,
                content TEXT,
                mood_score INTEGER,
                create_date TEXT,
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS chat_messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                goal_id INTEGER,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS creations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                type TEXT DEFAULT 'note',
                is_archived BOOLEAN DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                goal_id INTEGER,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            )
        """)

        cursor.execute("""
            CREATE TABLE IF NOT EXISTS notifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                message TEXT NOT NULL,
                type TEXT DEFAULT 'briefing',
                is_read BOOLEAN DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Simple Migrations for existing databases
        for table, col in [("goals", "is_archived"), ("tasks", "last_completed"), ("creations", "is_archived")]:
            try:
                cursor.execute(f"ALTER TABLE {table} ADD COLUMN {col} TEXT DEFAULT NULL")
            except:
                pass # Already exists

    print("✅ Database initialized at:", DB_PATH)


# ---------------------------------------------------------------------------
# CRUD Helpers
# ---------------------------------------------------------------------------

def dict_from_row(row):
    """Convert a sqlite3.Row to a plain dict."""
    if row is None:
        return None
    return dict(row)


def rows_to_list(rows):
    """Convert a list of sqlite3.Row objects to a list of dicts."""
    return [dict(r) for r in rows]
