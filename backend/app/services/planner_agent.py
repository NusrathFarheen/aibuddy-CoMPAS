"""
Planner Agent — Goal Decomposition AI
Automatically breaks high-level goals into actionable steps/tasks using Groq.
"""

import os
import json
from groq import Groq
from ..database import get_db, q

_client = None


def _get_client():
    global _client
    if _client is None:
        _client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    return _client


PLANNER_SYSTEM_PROMPT = """You are the Planner Agent of CoM-PAS. Your job is to break down high-level goals into concrete, actionable tasks.

Rules:
1. Generate 5-8 specific, actionable steps
2. Each step should be completable in 1-3 hours
3. Order them logically (dependencies first)
4. Be practical and realistic
5. Include research/learning steps when needed

IMPORTANT: Respond ONLY with a JSON array of task descriptions. No markdown, no explanation.
Example: ["Research Flutter basics", "Set up development environment", "Build first widget"]"""


def generate_plan(goal_id: int, title: str, description: str = "", template_id: str = "daily", user_id: int = None, api_key: str = None):
    """
    Generate an AI plan for a goal and save tasks to the database for a specific user.
    """
    context_hint = f"This goal uses the '{template_id}' template."
    
    prompt = f"Goal: {title}\nContext: {context_hint}"
    if description:
        prompt += f"\nDetails: {description}"
    prompt += "\n\nBreak this into 5-8 actionable steps suitable for this context."

    try:
        client = Groq(api_key=api_key) if api_key else _get_client()
             
        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": PLANNER_SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
            ],
            model="llama-3.3-70b-versatile", # Updated model name
            temperature=0.6,
            max_tokens=500,
        )

        raw = response.choices[0].message.content.strip()

        # Parse the JSON array — handle potential markdown wrapping
        if raw.startswith("```"):
            raw = raw.split("\n", 1)[1]  # Remove first line
            raw = raw.rsplit("```", 1)[0]  # Remove last ```

        tasks_list = json.loads(raw)

        if not isinstance(tasks_list, list):
            tasks_list = [str(tasks_list)]

    except (json.JSONDecodeError, Exception) as e:
        # Fallback: create generic planning tasks
        tasks_list = [
            f"Research: {title}",
            f"Create a detailed plan for: {title}",
            f"Begin working on: {title}",
            f"Review progress on: {title}",
            f"Complete and review: {title}",
        ]

    # Save tasks to database
    created_tasks = []
    with get_db() as conn:
        for desc in tasks_list:
            cursor = conn.execute(
                q("INSERT INTO tasks (goal_id, user_id, description, status) VALUES (?, ?, ?, 'todo')"),
                (goal_id, user_id, str(desc)),
            )
            created_tasks.append({
                "id": cursor.lastrowid,
                "goal_id": goal_id,
                "user_id": user_id,
                "description": str(desc),
                "is_completed": False,
                "status": "todo",
            })

    return created_tasks
