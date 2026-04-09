"""
AIBuddy (CoM-PAS) — Database Layer
SQLite database connection, table creation, and CRUD helpers.
Schema matches the original planner.db exactly.
"""

import sqlite3
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from contextlib import contextmanager

# Database lives at project root (next to backend/) or provided via environment
DB_URL = os.getenv("DATABASE_URL")
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "planner.db")

def is_postgres():
    return DB_URL is not None and (DB_URL.startswith("postgres://") or DB_URL.startswith("postgresql://"))

def get_db_url():
    """Fixes postgres:// to postgresql:// if needed for psycopg2."""
    if DB_URL and DB_URL.startswith("postgres://"):
        return DB_URL.replace("postgres://", "postgresql://", 1)
    return DB_URL

class CursorWrapper:
    def __init__(self, cursor, is_insert):
        self.cursor = cursor
        self._lastrowid = None
        if is_insert:
            try:
                row = self.cursor.fetchone()
                if row and 'id' in row:
                    self._lastrowid = row['id']
            except Exception:
                pass

    def fetchone(self):
        return self.cursor.fetchone()

    def fetchall(self):
        return self.cursor.fetchall()

    def __iter__(self):
        return iter(self.cursor)

    @property
    def lastrowid(self):
        return self._lastrowid

class PostgresConnectionWrapper:
    def __init__(self, conn):
        self._conn = conn

    def cursor(self, *args, **kwargs):
        return self._conn.cursor(cursor_factory=RealDictCursor)

    def execute(self, query, params=None):
        cursor = self._conn.cursor(cursor_factory=RealDictCursor)
        if params is None:
            cursor.execute(query)
        else:
            cursor.execute(query, params)
        is_insert = query.strip().upper().startswith("INSERT INTO")
        return CursorWrapper(cursor, is_insert)

    def commit(self):
        self._conn.commit()

    def rollback(self):
        self._conn.rollback()

    def close(self):
        self._conn.close()

@contextmanager
def get_db():
    """Context manager for database connections (SQLite or Postgres)."""
    if is_postgres():
        raw_conn = psycopg2.connect(get_db_url())
        conn = PostgresConnectionWrapper(raw_conn)
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()
    else:
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

        # Users table (New)
        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS users (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE,
                password_hash TEXT NOT NULL,
                groq_api_key TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS goals (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                user_id INTEGER REFERENCES users(id),
                title TEXT NOT NULL,
                description TEXT,
                deadline TEXT,
                progress INTEGER DEFAULT 0,
                status TEXT DEFAULT 'active',
                is_pinned BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' },
                current_value INTEGER DEFAULT 0,
                target_value INTEGER DEFAULT 100,
                template_id TEXT DEFAULT 'daily',
                current_stage INTEGER DEFAULT 0,
                author_name TEXT,
                author_orcid TEXT,
                author_affiliation TEXT,
                is_archived BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' },
                is_deleted BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' }
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS tasks (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                goal_id INTEGER REFERENCES goals(id),
                user_id INTEGER REFERENCES users(id),
                description TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' },
                scheduled_date TEXT,
                last_completed TEXT,
                status TEXT DEFAULT 'todo'
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS routines (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                user_id INTEGER REFERENCES users(id),
                title TEXT NOT NULL,
                is_completed BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' },
                category TEXT DEFAULT 'general',
                last_completed_date TEXT,
                current_streak INTEGER DEFAULT 0,
                best_streak INTEGER DEFAULT 0
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS creations (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                user_id INTEGER REFERENCES users(id),
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                type TEXT DEFAULT 'note',
                is_archived BOOLEAN DEFAULT { 'FALSE' if is_postgres() else '0' },
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS fitness_logs (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                user_id INTEGER REFERENCES users(id),
                goal_id INTEGER REFERENCES goals(id),
                date TEXT NOT NULL,
                type TEXT NOT NULL,
                category TEXT,
                value TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS progress_photos (
                id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' },
                user_id INTEGER REFERENCES users(id),
                goal_id INTEGER REFERENCES goals(id),
                date TEXT NOT NULL,
                image_path TEXT NOT NULL,
                caption TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Shared/Relational tables
        cursor.execute(f"CREATE TABLE IF NOT EXISTS chat_messages (id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' }, user_id INTEGER REFERENCES users(id), goal_id INTEGER REFERENCES goals(id), role TEXT NOT NULL, content TEXT NOT NULL, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
        cursor.execute(f"CREATE TABLE IF NOT EXISTS notes (id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' }, user_id INTEGER REFERENCES users(id), goal_id INTEGER REFERENCES goals(id), title TEXT NOT NULL, content TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
        cursor.execute(f"CREATE TABLE IF NOT EXISTS references_links (id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' }, user_id INTEGER REFERENCES users(id), goal_id INTEGER REFERENCES goals(id), title TEXT NOT NULL, url TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)")
        cursor.execute(f"CREATE TABLE IF NOT EXISTS journal_entries (id { 'SERIAL' if is_postgres() else 'INTEGER' } PRIMARY KEY { '' if is_postgres() else 'AUTOINCREMENT' }, user_id INTEGER REFERENCES users(id), goal_id INTEGER REFERENCES goals(id), content TEXT, mood_score INTEGER, create_date TEXT)")

        if not is_postgres():
            # Simple Migrations for Existing Tables
            migration_cols = [
                ("goals", "user_id", "INTEGER REFERENCES users(id)"),
                ("tasks", "user_id", "INTEGER REFERENCES users(id)"),
                ("routines", "user_id", "INTEGER REFERENCES users(id)"),
                ("creations", "user_id", "INTEGER REFERENCES users(id)"),
                ("fitness_logs", "user_id", "INTEGER REFERENCES users(id)"),
                ("progress_photos", "user_id", "INTEGER REFERENCES users(id)")
            ]
            for table, col, def_val in migration_cols:
                try:
                    cursor.execute(f"ALTER TABLE {table} ADD COLUMN {col} {def_val}")
                except:
                    pass 

            # Simple Migrations for existing databases
            migration_cols2 = [
                ("goals", "is_archived", "TEXT DEFAULT NULL"),
                ("tasks", "last_completed", "TEXT DEFAULT NULL"), 
                ("creations", "is_archived", "TEXT DEFAULT NULL"),
                ("goals", "current_stage", "INTEGER DEFAULT 0"),
                ("goals", "author_name", "TEXT"),
                ("goals", "author_orcid", "TEXT"),
                ("goals", "author_affiliation", "TEXT")
            ]
            for table, col, def_val in migration_cols2:
                try:
                    cursor.execute(f"ALTER TABLE {table} ADD COLUMN {col} {def_val}")
                except:
                    pass # Already exists

    print(f"✅ Database initialized ({'Postgres' if is_postgres() else 'SQLite'})")


import re
def q(query):
    """Normalizes query placeholders for SQLite (?) vs Postgres (%s) and injects RETURNING id."""
    if is_postgres():
        replaced = query.replace("?", "%s")
        if replaced.strip().upper().startswith("INSERT INTO") and " RETURNING id" not in replaced:
            replaced += " RETURNING id"
            
        # Fix SQLite literal integers to Postgres BOOLEAN
        replaced = re.sub(r'is_deleted\s*=\s*0', 'is_deleted = FALSE', replaced)
        replaced = re.sub(r'is_deleted\s*=\s*1', 'is_deleted = TRUE', replaced)
        replaced = re.sub(r'is_completed\s*=\s*0', 'is_completed = FALSE', replaced)
        replaced = re.sub(r'is_completed\s*=\s*1', 'is_completed = TRUE', replaced)
        replaced = re.sub(r'is_pinned\s*=\s*0', 'is_pinned = FALSE', replaced)
        replaced = re.sub(r'is_pinned\s*=\s*1', 'is_pinned = TRUE', replaced)
        replaced = re.sub(r'is_archived\s*=\s*0', 'is_archived = FALSE', replaced)
        replaced = re.sub(r'is_archived\s*=\s*1', 'is_archived = TRUE', replaced)
        return replaced
    return query


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
