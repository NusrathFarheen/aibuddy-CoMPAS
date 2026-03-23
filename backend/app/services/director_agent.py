"""
Director Agent — The "Boss" AI of CoM-PAS
Generates personalized daily briefings by analyzing goals, deadlines, mood, and habits.
Personality: Professional yet witty (JARVIS/FRIDAY inspired).
"""

import os
from datetime import datetime, timedelta
from groq import Groq
from ..database import get_db, rows_to_list

_client = None


def _get_client():
    global _client
    if _client is None:
        _client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    return _client


DIRECTOR_SYSTEM_PROMPT = """You are the Director — the proactive AI brain of CoM-PAS (Cognitive Management & Proactive Assistance System). 

Your personality:
- Professional yet witty, like JARVIS or FRIDAY from Marvel
- You genuinely care about the user's wellbeing and progress
- You use occasional humor but stay focused on actionable insights
- When mood is low, you're encouraging and warm
- When things are going well, you celebrate and push for more
- You address the user directly, like a personal chief of staff

Your job is to analyze the user's current state and provide a concise, actionable daily briefing.
Keep it to 3-5 key points. Be specific about goals, deadlines, and mood trends.
Use emoji sparingly for emphasis. End with one motivating line."""


def get_briefing():
    """
    Generate the Director's daily briefing.
    Gathers context from goals, mood, habits, then calls Groq for the briefing.
    """
    context = _gather_context()
    prompt = _build_prompt(context)

    try:
        client = _get_client()
        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": DIRECTOR_SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=500,
        )
        briefing_text = response.choices[0].message.content

        # Save as notification
        _save_notification("Director's Briefing", briefing_text)

        return {
            "briefing": briefing_text,
            "context": context,
            "generated_at": datetime.now().isoformat(),
        }

    except Exception as e:
        fallback = f"⚠️ Director is temporarily offline: {str(e)}"
        return {
            "briefing": fallback,
            "context": context,
            "generated_at": datetime.now().isoformat(),
            "error": str(e),
        }


def _gather_context():
    """Pull all relevant user data for the briefing."""
    context = {}
    today = datetime.now().strftime("%Y-%m-%d")

    with get_db() as conn:
        cursor = conn.cursor()

        # Active goals with deadline status
        cursor.execute(
            "SELECT * FROM goals WHERE status = 'active' AND is_deleted = 0"
        )
        goals = rows_to_list(cursor.fetchall())

        for g in goals:
            if g.get("deadline"):
                try:
                    dl = datetime.strptime(g["deadline"], "%Y-%m-%d")
                    days_left = (dl - datetime.now()).days
                    if days_left < 0:
                        g["deadline_status"] = "OVERDUE"
                    elif days_left == 0:
                        g["deadline_status"] = "DUE TODAY"
                    elif days_left <= 3:
                        g["deadline_status"] = "URGENT"
                    else:
                        g["deadline_status"] = "On Target"
                    g["days_left"] = days_left
                except ValueError:
                    g["deadline_status"] = "Unknown"

        context["goals"] = goals
        context["goal_count"] = len(goals)

        # Recent mood (last 7 days of journal entries)
        week_ago = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
        cursor.execute(
            "SELECT mood_score, create_date FROM journal_entries WHERE create_date >= ? ORDER BY create_date DESC",
            (week_ago,),
        )
        moods = rows_to_list(cursor.fetchall())
        context["recent_moods"] = moods
        if moods:
            avg_mood = sum(m["mood_score"] for m in moods if m["mood_score"]) / max(
                len([m for m in moods if m["mood_score"]]), 1
            )
            context["avg_mood"] = round(avg_mood, 1)
        else:
            context["avg_mood"] = None

        # Latest journal entry
        cursor.execute(
            "SELECT content, mood_score, create_date FROM journal_entries ORDER BY id DESC LIMIT 1"
        )
        latest_journal = cursor.fetchone()
        context["latest_journal"] = dict(latest_journal) if latest_journal else None

        # Habit streaks
        cursor.execute("SELECT title, current_streak, best_streak FROM routines")
        context["habits"] = rows_to_list(cursor.fetchall())

        # Pending tasks count
        cursor.execute(
            "SELECT COUNT(*) as count FROM tasks WHERE is_completed = 0"
        )
        context["pending_tasks"] = cursor.fetchone()["count"]

    return context


def _build_prompt(context):
    """Build the user-context prompt for the Director."""
    today = datetime.now().strftime("%A, %B %d, %Y")
    hour = datetime.now().hour
    greeting = "Good morning" if hour < 12 else "Good afternoon" if hour < 17 else "Good evening"

    lines = [f"Current date/time: {today}, {greeting} time."]
    lines.append(f"The user has {context['goal_count']} active goal(s) and {context['pending_tasks']} pending tasks.")

    if context["goals"]:
        lines.append("\n📋 ACTIVE GOALS:")
        for g in context["goals"]:
            status = g.get("deadline_status", "")
            progress = g.get("progress", 0)
            lines.append(
                f"  - '{g['title']}': {progress}% done. Deadline: {g.get('deadline', 'none')} [{status}]"
            )

    if context["avg_mood"] is not None:
        mood_desc = (
            "very low" if context["avg_mood"] <= 1.5
            else "low" if context["avg_mood"] <= 2.5
            else "moderate" if context["avg_mood"] <= 3.5
            else "good" if context["avg_mood"] <= 4.5
            else "excellent"
        )
        lines.append(f"\n😊 MOOD: Average mood this week is {context['avg_mood']}/5 ({mood_desc}).")

    if context["latest_journal"]:
        j = context["latest_journal"]
        lines.append(f"Latest journal ({j.get('create_date', 'recent')}): \"{j.get('content', '')[:200]}\"")

    if context["habits"]:
        lines.append("\n🔥 HABIT STREAKS:")
        for h in context["habits"]:
            lines.append(f"  - '{h['title']}': {h['current_streak']} day streak (best: {h['best_streak']})")

    lines.append("\nGenerate a personalized daily briefing based on this data.")
    return "\n".join(lines)


def _save_notification(title, message):
    """Save the briefing as a notification."""
    try:
        with get_db() as conn:
            conn.execute(
                "INSERT INTO notifications (title, message, type) VALUES (?, ?, 'briefing')",
                (title, message),
            )
    except Exception:
        pass  # Non-critical
