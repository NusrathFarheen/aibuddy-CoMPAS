"""
AIBuddy (CoM-PAS) — FastAPI Main Application
Central command center hosting all API endpoints, AI agents, and memory initialization.
"""

import os
from datetime import datetime, date, timedelta
from dotenv import load_dotenv

# Load .env from project root
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"))

from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import Optional, List, Any
import uuid
import shutil

from .database import init_db, get_db, dict_from_row, rows_to_list
from .services.memory import init_memory, store_memory, search_memory, get_workspace_stats
from .services.director_agent import get_briefing
from .services.planner_agent import generate_plan
from .services.chat_agent import chat, get_chat_history

# ============================================================================
# App Setup
# ============================================================================

app = FastAPI(
    title="AIBuddy (CoM-PAS)",
    description="Cognitive Management & Proactive Assistance System — Your AI Operating System",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False, # Changed to False to allow wildcard origins in browser
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():
    """Initialize database and memory on startup."""
    print("\n🧠 AIBuddy (CoM-PAS) — Starting up...")
    
    # Ensure uploads directory exists
    os.makedirs(os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads"), exist_ok=True)
    
    init_db()
    try:
        init_memory()
    except Exception as e:
        print(f"⚠️ Memory init warning (non-critical): {e}")
    print("🚀 CoM-PAS is ONLINE.\n")

# Serve the uploads directory
app.mount("/uploads", StaticFiles(directory=os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")), name="uploads")

@app.get("/")
async def root():
    return {
        "status": "online",
        "message": "AIBuddy (CoM-PAS) Backend is running.",
        "version": "2.0.0"
    }


# ============================================================================
# Pydantic Models (Request Bodies)
# ============================================================================

class GoalCreate(BaseModel):
    title: str
    description: Optional[str] = ""
    deadline: Optional[str] = None
    template_id: Optional[str] = "daily"

class GoalUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    deadline: Optional[str] = None
    progress: Optional[int] = None
    status: Optional[str] = None
    is_pinned: Optional[bool] = None
    current_value: Optional[int] = None
    target_value: Optional[int] = None
    template_id: Optional[str] = None
    is_archived: Optional[int] = None
    current_stage: Optional[int] = None
    author_name: Optional[str] = None
    author_orcid: Optional[str] = None
    author_affiliation: Optional[str] = None

class TaskUpdate(BaseModel):
    description: Optional[str] = None
    is_completed: Optional[bool] = None
    status: Optional[str] = None
    scheduled_date: Optional[str] = None
    last_completed: Optional[str] = None

class RoutineCreate(BaseModel):
    title: str
    category: Optional[str] = "general"

class JournalCreate(BaseModel):
    content: str
    mood_score: Optional[int] = 3
    goal_id: Optional[int] = None

class CreationCreate(BaseModel):
    type: Optional[str] = "note"

class CreationUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    type: Optional[str] = None
    is_archived: Optional[int] = None

class NoteCreate(BaseModel):
    goal_id: Optional[int] = None
    title: str
    content: str

class ReferenceCreate(BaseModel):
    goal_id: int
    title: str
    url: str

class FitnessLogCreate(BaseModel):
    goal_id: int
    date: str
    type: str # 'workout', 'diet', 'metric'
    category: Optional[str] = None
    value: str # JSON string

class FitnessPhotoCreate(BaseModel):
    goal_id: int
    date: str
    image_path: str
    caption: Optional[str] = None

class ChatMessage(BaseModel):
    message: str
    goal_id: Optional[int] = None
    system_instruction: Optional[str] = None

class MemoryStore(BaseModel):
    workspace: str
    text: str
    metadata: Optional[dict] = None

class MemorySearch(BaseModel):
    workspace: str
    query: str
    n_results: Optional[int] = 5


# ============================================================================
# Health & Director
# ============================================================================

@app.get("/")
def root():
    return {
        "name": "AIBuddy (CoM-PAS)",
        "status": "online",
        "version": "2.0.0",
        "message": "Cognitive Management & Proactive Assistance System — Ready.",
    }


from fastapi import Request

@app.get("/director/briefing")
def director_briefing(request: Request):
    """Get the Director's personalized daily briefing."""
    # Extract Groq key from headers if present
    api_key = request.headers.get("X-Groq-Key")
    # Use user_id=None to trigger Single User Mode resilience
    return get_briefing(user_id=None, api_key=api_key)


# ============================================================================
# GOALS
# ============================================================================

@app.get("/api/goals")
def list_goals():
    """List all active (non-deleted) goals."""
    with get_db() as conn:
        cursor = conn.execute(
            "SELECT * FROM goals WHERE is_deleted = 0 ORDER BY is_pinned DESC, id DESC"
        )
        return rows_to_list(cursor.fetchall())


@app.get("/api/goals/{goal_id}/references")
def list_references(goal_id: int):
    """List all references for a goal."""
    with get_db() as conn:
        cursor = conn.execute(
            "SELECT * FROM references_links WHERE goal_id = ? ORDER BY created_at DESC", (goal_id,)
        )
        return rows_to_list(cursor.fetchall())


@app.post("/api/references")
def create_reference(ref: ReferenceCreate):
    """Create a new reference link."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO references_links (goal_id, title, url) VALUES (?, ?, ?)",
            (ref.goal_id, ref.title, ref.url),
        )
        row = conn.execute("SELECT * FROM references_links WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


@app.delete("/api/references/{ref_id}")
def delete_reference(ref_id: int):
    """Delete a reference link."""
    with get_db() as conn:
        conn.execute("DELETE FROM references_links WHERE id = ?", (ref_id,))
        return {"message": "Reference deleted", "id": ref_id}


@app.post("/api/goals/{goal_id}/finalize")
def finalize_goal(goal_id: int):
    """Mock endpoint for generating final output (PDF)."""
    # Logic for actual PDF generation could go here
    return {"message": "Output generated successfully!", "goal_id": goal_id}


@app.post("/api/goals")
def create_goal(goal: GoalCreate):
    """Create a new goal and auto-generate tasks via the Planner Agent."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO goals (title, description, deadline, template_id) VALUES (?, ?, ?, ?)",
            (goal.title, goal.description, goal.deadline, goal.template_id),
        )
        goal_id = cursor.lastrowid

    # Trigger Planner Agent to break goal into tasks
    try:
        tasks = generate_plan(goal_id, goal.title, goal.description, goal.template_id)
    except Exception as e:
        tasks = []
        print(f"⚠️ Planner Agent error: {e}")

    # Store in task memory
    try:
        store_memory(
            "task_workspace",
            f"New goal created: {goal.title}. {goal.description}",
            metadata={"type": "goal", "goal_id": str(goal_id)},
        )
    except Exception:
        pass

    with get_db() as conn:
        row = conn.execute("SELECT * FROM goals WHERE id = ?", (goal_id,)).fetchone()
        return {
            "goal": dict_from_row(row),
            "generated_tasks": tasks,
            "message": f"Goal created with {len(tasks)} AI-generated tasks!",
        }


@app.get("/api/goals/{goal_id}")
def get_goal(goal_id: int):
    """Get a single goal by ID."""
    with get_db() as conn:
        row = conn.execute("SELECT * FROM goals WHERE id = ? AND is_deleted = 0", (goal_id,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Goal not found")
        return dict_from_row(row)


@app.put("/api/goals/{goal_id}")
def update_goal(goal_id: int, update: GoalUpdate):
    """Update goal fields."""
    updates = {k: v for k, v in update.model_dump().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    set_clause = ", ".join(f"{k} = ?" for k in updates)
    values = list(updates.values()) + [goal_id]

    with get_db() as conn:
        conn.execute(f"UPDATE goals SET {set_clause} WHERE id = ?", values)
        row = conn.execute("SELECT * FROM goals WHERE id = ?", (goal_id,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Goal not found")
        return dict_from_row(row)


@app.delete("/api/goals/{goal_id}")
def delete_goal(goal_id: int):
    """Soft-delete a goal (set is_deleted = 1)."""
    with get_db() as conn:
        conn.execute("UPDATE goals SET is_deleted = 1 WHERE id = ?", (goal_id,))
        return {"message": "Goal archived", "id": goal_id}


# ============================================================================
# TASKS
# ============================================================================

@app.get("/api/goals/{goal_id}/tasks")
def list_tasks(goal_id: int):
    """Get all tasks for a goal."""
    with get_db() as conn:
        cursor = conn.execute(
            "SELECT * FROM tasks WHERE goal_id = ? ORDER BY id ASC", (goal_id,)
        )
        return rows_to_list(cursor.fetchall())


@app.get("/api/tasks")
def list_all_tasks():
    """Get all tasks across all goals."""
    with get_db() as conn:
        cursor = conn.execute("SELECT * FROM tasks ORDER BY id DESC")
        return rows_to_list(cursor.fetchall())


@app.put("/api/tasks/{task_id}")
def update_task(task_id: int, update: TaskUpdate):
    """Update a task's status / completion."""
    updates = {k: v for k, v in update.model_dump().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    # If marking complete, also set status to 'done'
    if updates.get("is_completed"):
        updates["status"] = "done"

    set_clause = ", ".join(f"{k} = ?" for k in updates)
    values = list(updates.values()) + [task_id]

    with get_db() as conn:
        conn.execute(f"UPDATE tasks SET {set_clause} WHERE id = ?", values)

        # Auto-update goal progress
        row = conn.execute("SELECT goal_id FROM tasks WHERE id = ?", (task_id,)).fetchone()
        if row:
            _update_goal_progress(conn, row["goal_id"])

        updated = conn.execute("SELECT * FROM tasks WHERE id = ?", (task_id,)).fetchone()
        if not updated:
            raise HTTPException(status_code=404, detail="Task not found")
        return dict_from_row(updated)


def _update_goal_progress(conn, goal_id):
    """Recalculate goal progress based on completed tasks."""
    if not goal_id:
        return
    cursor = conn.execute(
        "SELECT COUNT(*) as total, SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as done FROM tasks WHERE goal_id = ?",
        (goal_id,),
    )
    row = cursor.fetchone()
    total = row["total"]
    done = row["done"] or 0
    progress = int((done / total) * 100) if total > 0 else 0
    conn.execute("UPDATE goals SET progress = ? WHERE id = ?", (progress, goal_id))


# ============================================================================
# ROUTINES (Habits)
# ============================================================================

@app.get("/api/routines")
def list_routines():
    """List all routines, grouped by category, with daily reset check."""
    today = date.today().isoformat()
    with get_db() as conn:
        # 1. Perform daily reset check
        # If any routine is marked as completed but its last_completed_date is NOT today,
        # it means a new day has started, and we should reset 'is_completed' for ALL routines.
        # This acts as our "cron jobs substitute" on every fetch.
        stale_check = conn.execute(
            "SELECT count(*) FROM routines WHERE is_completed = 1 AND last_completed_date != ?", (today,)
        ).fetchone()[0]
        
        if stale_check > 0:
            conn.execute("UPDATE routines SET is_completed = 0")
            # Update last_completed_date to NULL for routines that haven't been completed today?
            # No, keep it so we know if the streak was broken tomorrow.

        cursor = conn.execute("SELECT * FROM routines ORDER BY category, id")
        routines = rows_to_list(cursor.fetchall())
        # Add badge info
        for r in routines:
            r["badge"] = _get_badge(r["current_streak"] or 0)
        return routines


@app.post("/api/routines")
def create_routine(routine: RoutineCreate):
    """Create a new routine/habit."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO routines (title, category) VALUES (?, ?)",
            (routine.title, routine.category),
        )
        row = conn.execute("SELECT * FROM routines WHERE id = ?", (cursor.lastrowid,)).fetchone()
        result = dict_from_row(row)
        result["badge"] = _get_badge(0)
        return result


@app.put("/api/routines/{routine_id}/complete")
def toggle_routine(routine_id: int):
    """Toggle a routine's completion status for today with streak consistency."""
    today = date.today().isoformat()
    yesterday = (date.today() - timedelta(days=1)).isoformat()

    with get_db() as conn:
        row = conn.execute("SELECT * FROM routines WHERE id = ?", (routine_id,)).fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Routine not found")

        routine = dict(row)
        last_date = routine.get("last_completed_date")
        current_streak = int(routine.get("current_streak") or 0)
        best_streak = int(routine.get("best_streak") or 0)
        is_already_done = bool(routine.get("is_completed"))

        if last_date == today:
            # We are toggling a completion that already happened TODAY
            if is_already_done:
                # Toggling OFF: set is_completed to 0 and revert the streak increment
                new_status = 0
                current_streak = max(0, current_streak - 1)
            else:
                # Toggling back ON: set is_completed back to 1 and re-increment streak
                new_status = 1
                current_streak += 1
        else:
            # This is the FIRST completion of the day (or first after reset)
            new_status = 1
            if last_date == yesterday:
                # Continuing streak!
                current_streak += 1
            else:
                # Streak broken yesterday, restart
                current_streak = 1
        
        best_streak = max(best_streak, current_streak)

        conn.execute(
            "UPDATE routines SET is_completed = ?, last_completed_date = ?, current_streak = ?, best_streak = ? WHERE id = ?",
            (new_status, today, current_streak, best_streak, routine_id),
        )

        # Store in wellness memory (only on completion)
        if new_status == 1:
            try:
                store_memory(
                    "wellness_workspace",
                    f"Completed habit: {routine['title']}. Streak: {current_streak} days.",
                    metadata={"type": "habit", "streak": str(current_streak)},
                )
            except Exception:
                pass

        updated = conn.execute("SELECT * FROM routines WHERE id = ?", (routine_id,)).fetchone()
        result = dict_from_row(updated)
        result["badge"] = _get_badge(current_streak)
        return result


@app.put("/api/routines/reset-daily")
def reset_daily_routines():
    """Reset all routine completion status for a new day."""
    with get_db() as conn:
        conn.execute("UPDATE routines SET is_completed = 0")
        return {"message": "Daily routines reset"}


def _get_badge(streak: int) -> str:
    """Determine badge based on streak count."""
    if streak >= 30:
        return "🏆 Unstoppable"
    elif streak >= 14:
        return "💎 Diamond"
    elif streak >= 7:
        return "🔥 On Fire"
    elif streak >= 3:
        return "⭐ Starter"
    else:
        return "🌱 Beginner"


# ============================================================================
# JOURNAL
# ============================================================================

@app.get("/api/journal")
def list_journal():
    """List all journal entries, most recent first."""
    with get_db() as conn:
        cursor = conn.execute("SELECT * FROM journal_entries ORDER BY id DESC")
        return rows_to_list(cursor.fetchall())


@app.post("/api/journal")
def create_journal(entry: JournalCreate):
    """Create a journal entry with mood score."""
    today = date.today().isoformat()

    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO journal_entries (goal_id, content, mood_score, create_date) VALUES (?, ?, ?, ?)",
            (entry.goal_id, entry.content, entry.mood_score, today),
        )

        # Store mood data in wellness memory
        try:
            store_memory(
                "wellness_workspace",
                f"Journal entry (mood: {entry.mood_score}/5): {entry.content}",
                metadata={"type": "journal", "mood": str(entry.mood_score), "date": today},
            )
        except Exception:
            pass

        row = conn.execute("SELECT * FROM journal_entries WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


# ============================================================================
# CREATIONS (Knowledge Base)
# ============================================================================

@app.get("/api/creations")
def list_creations():
    """List all creations/ideas."""
    with get_db() as conn:
        cursor = conn.execute("SELECT * FROM creations ORDER BY created_at DESC")
        return rows_to_list(cursor.fetchall())


@app.post("/api/creations")
def create_creation(creation: CreationCreate):
    """Create a new creation/idea."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO creations (title, content, type) VALUES (?, ?, ?)",
            (creation.title, creation.content, creation.type),
        )

        # Store in research memory
        try:
            store_memory(
                "research_workspace",
                f"{creation.title}: {creation.content}",
                metadata={"type": creation.type},
            )
        except Exception:
            pass

        row = conn.execute("SELECT * FROM creations WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


@app.delete("/api/creations/{item_id}")
async def delete_creation(item_id: int):
    with get_db() as conn:
        conn.execute("DELETE FROM creations WHERE id = ?", (item_id,))
    return {"status": "success"}

@app.put("/api/creations/{item_id}")
async def update_creation(item_id: int, updates: CreationUpdate):
    with get_db() as conn:
        update_data = updates.dict(exclude_unset=True)
        if not update_data:
            return {"status": "no updates"}
        
        set_clause = ", ".join([f"{k} = ?" for k in update_data.keys()])
        params = list(update_data.values()) + [item_id]
        conn.execute(f"UPDATE creations SET {set_clause} WHERE id = ?", params)
    return {"status": "success"}


# ============================================================================
# NOTES
# ============================================================================

@app.get("/api/notes")
def list_notes():
    """List all notes."""
    with get_db() as conn:
        cursor = conn.execute("SELECT * FROM notes ORDER BY created_at DESC")
        return rows_to_list(cursor.fetchall())


@app.get("/api/goals/{goal_id}/notes")
def list_goal_notes(goal_id: int):
    """List notes for a specific goal."""
    with get_db() as conn:
        cursor = conn.execute(
            "SELECT * FROM notes WHERE goal_id = ? ORDER BY created_at DESC", (goal_id,)
        )
        return rows_to_list(cursor.fetchall())


@app.post("/api/notes")
def create_note(note: NoteCreate):
    """Create a new note."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO notes (goal_id, title, content) VALUES (?, ?, ?)",
            (note.goal_id, note.title, note.content),
        )
        
        # Store in task memory for H-MACE
        try:
            store_memory(
                "task_workspace",
                f"{note.title}: {note.content}",
                metadata={"type": "note", "goal_id": str(note.goal_id) if note.goal_id else ""},
            )
        except Exception:
            pass
            
        row = conn.execute("SELECT * FROM notes WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


@app.delete("/api/notes/{note_id}")
def delete_note(note_id: int):
    """Delete a note."""
    with get_db() as conn:
        conn.execute("DELETE FROM notes WHERE id = ?", (note_id,))
        return {"message": "Note deleted", "id": note_id}


# ============================================================================
# CHAT
# ============================================================================

@app.post("/api/chat")
def send_chat(msg: ChatMessage):
    """Send a message to the Chat Agent and get an AI response."""
    return chat(msg.message, msg.goal_id, msg.system_instruction)


@app.get("/api/chat/history")
def chat_history(goal_id: Optional[int] = None, limit: int = 50):
    """Get chat message history."""
    return get_chat_history(goal_id, limit)


# ============================================================================
# NOTIFICATIONS
# ============================================================================

@app.get("/api/notifications")
def list_notifications():
    """List all notifications."""
    with get_db() as conn:
        cursor = conn.execute("SELECT * FROM notifications ORDER BY created_at DESC LIMIT 50")
        return rows_to_list(cursor.fetchall())


@app.put("/api/notifications/{notif_id}/read")
def mark_notification_read(notif_id: int):
    """Mark a notification as read."""
    with get_db() as conn:
        conn.execute("UPDATE notifications SET is_read = 1 WHERE id = ?", (notif_id,))
        return {"message": "Marked as read"}


# ============================================================================
# FITNESS & HEALTH
# ============================================================================

@app.get("/api/goals/{goal_id}/fitness/logs")
def list_fitness_logs(goal_id: int, log_type: Optional[str] = None):
    """List fitness logs for a specific goal."""
    with get_db() as conn:
        query = "SELECT * FROM fitness_logs WHERE goal_id = ? "
        params: list = [goal_id]
        if log_type:
            query += "AND type = ? "
            params.append(log_type)
        query += "ORDER BY date DESC, created_at DESC"
        cursor = conn.execute(query, params)
        return rows_to_list(cursor.fetchall())


@app.post("/api/fitness/logs")
def create_fitness_log(log: FitnessLogCreate):
    """Create a new fitness log (workout, diet, or metric)."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO fitness_logs (goal_id, date, type, category, value) VALUES (?, ?, ?, ?, ?)",
            (log.goal_id, log.date, log.type, log.category, log.value),
        )
        row = conn.execute("SELECT * FROM fitness_logs WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


@app.get("/api/goals/{goal_id}/fitness/photos")
def list_fitness_photos(goal_id: int):
    """List progress photos for a fitness goal."""
    with get_db() as conn:
        cursor = conn.execute(
            "SELECT * FROM progress_photos WHERE goal_id = ? ORDER BY date DESC", (goal_id,)
        )
        return rows_to_list(cursor.fetchall())


@app.post("/api/fitness/photos")
def create_fitness_photo(photo: FitnessPhotoCreate):
    """Log a new progress photo."""
    with get_db() as conn:
        cursor = conn.execute(
            "INSERT INTO progress_photos (goal_id, date, image_path, caption) VALUES (?, ?, ?, ?)",
            (photo.goal_id, photo.date, photo.image_path, photo.caption),
        )
        row = conn.execute("SELECT * FROM progress_photos WHERE id = ?", (cursor.lastrowid,)).fetchone()
        return dict_from_row(row)


@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    """Upload a file to the server/cloud and return its URL."""
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are allowed.")
    
    # Use Cloudinary if configured
    if os.getenv("CLOUDINARY_URL"):
        try:
            import cloudinary.uploader
            result = cloudinary.uploader.upload(file.file)
            return {"url": result["secure_url"]}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Cloudinary Upload Error: {e}")

    # Fallback to local upload
    filename = f"{uuid.uuid4()}_{file.filename}"
    upload_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads", filename)
    
    with open(upload_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    return {"url": f"/uploads/{filename}"}


# ============================================================================
# MEMORY (H-MACE) — Direct Access Endpoints
# ============================================================================

@app.get("/api/memory/stats")
def memory_stats():
    """Get memory usage stats per workspace."""
    try:
        return get_workspace_stats()
    except Exception as e:
        return {"error": str(e)}


@app.post("/api/memory/store")
def store_to_memory(data: MemoryStore):
    """Manually store something in memory."""
    doc_id = store_memory(data.workspace, data.text, data.metadata)
    return {"id": doc_id, "workspace": data.workspace}


@app.post("/api/memory/search")
def search_in_memory(data: MemorySearch):
    """Search memory semantically."""
    results = search_memory(data.workspace, data.query, data.n_results)
    return {"results": results, "count": len(results)}
