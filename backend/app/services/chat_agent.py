"""
Chat Agent — Conversational AI with RAG context from H-MACE memory.
Supports context-aware conversations with memory retrieval.
"""

import os
from groq import Groq
from ..database import get_db
from .memory import search_memory, store_memory

_client = None


def _get_client(api_key: str = None):
    if api_key:
        return Groq(api_key=api_key)
    global _client
    if _client is None:
        _client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    return _client


CHAT_SYSTEM_PROMPT = """You are CoM-PAS Chat — the user's personal AI assistant within the AIBuddy system.

Your personality:
- Friendly, warm, and genuinely helpful
- You remember context from previous conversations (provided below)
- You can help with planning, brainstorming, motivation, and general questions
- You're proactive — suggest next steps and improvements
- Keep responses concise but thorough
- Use emoji occasionally to keep things engaging

If relevant memories or context is provided, weave them naturally into your response.
You have access to the user's goals, habits, and journal data through the system."""


def chat(message: str, goal_id: int = None, system_instruction: str = None, api_key: str = None):
    """
    Process a chat message with RAG context.
    
    Args:
        message: User's message
        goal_id: Optional goal context
        
    Returns:
        Dict with 'response' and 'memories_used'
    """
    # 1. Search relevant memories
    memories = []
    for workspace in ["task_workspace", "research_workspace", "wellness_workspace"]:
        try:
            results = search_memory(workspace, message, n_results=3)
            memories.extend(results)
        except Exception:
            pass  # Memory might not be initialized

    # 2. Build context-enriched prompt
    context_block = ""
    if memories:
        context_block = "\n\n📚 RELEVANT CONTEXT FROM MEMORY:\n"
        for m in memories[:5]:  # Top 5 across all workspaces
            context_block += f"- {m['document'][:200]}\n"

    # 3. Get recent chat history for continuity
    history = _get_recent_history(goal_id, limit=10)

    # 4. Build messages
    base_prompt = CHAT_SYSTEM_PROMPT
    if system_instruction:
        base_prompt += f"\n\n[USER PERSONA INSTRUCTION]\n{system_instruction}\n\nMake sure to adopt this persona in your response."
        
    if goal_id:
        with get_db() as conn:
            row = conn.execute("SELECT title, description FROM goals WHERE id = ?", (goal_id,)).fetchone()
            if row:
                base_prompt += f"\n\n[CRITICAL INSTRUCTION] You are currently inside a dedicated Workspace for a specific goal: '{row['title']}'.\nGoal Description: '{row['description']}'.\nDo NOT ask the user which goal they want to work on. Focus ONLY on this specific goal, and use the user's Drafts and Notes provided in the context below to help them achieve it."

    messages = [{"role": "system", "content": base_prompt + context_block}]

    for h in history:
        messages.append({"role": h["role"], "content": h["content"]})

    messages.append({"role": "user", "content": message})

    # 5. Call Groq
    try:
        client = _get_client(api_key=api_key)
        response = client.chat.completions.create(
            messages=messages,
            model="llama-3.3-70b-versatile",
            temperature=0.7,
            max_tokens=800,
        )
        reply = response.choices[0].message.content
    except Exception as e:
        reply = f"I'm having trouble connecting right now. Error: {str(e)}"

    # 6. Save both messages to history
    _save_message(goal_id, "user", message)
    _save_message(goal_id, "assistant", reply)

    # 7. Store in task memory for future RAG
    try:
        store_memory(
            "task_workspace",
            f"User: {message}\nAssistant: {reply}",
            metadata={"type": "chat", "goal_id": str(goal_id) if goal_id else "general"},
        )
    except Exception:
        pass

    return {
        "response": reply,
        "memories_used": len(memories),
    }


def _get_recent_history(goal_id: int = None, limit: int = 10):
    """Fetch recent chat messages for context continuity."""
    with get_db() as conn:
        if goal_id:
            cursor = conn.execute(
                "SELECT role, content FROM chat_messages WHERE goal_id = ? ORDER BY id DESC LIMIT ?",
                (goal_id, limit),
            )
        else:
            cursor = conn.execute(
                "SELECT role, content FROM chat_messages ORDER BY id DESC LIMIT ?",
                (limit,),
            )
        rows = cursor.fetchall()
        # Reverse so oldest first
        return [dict(r) for r in reversed(rows)]


def _save_message(goal_id, role, content):
    """Save a chat message to the database."""
    try:
        with get_db() as conn:
            conn.execute(
                "INSERT INTO chat_messages (goal_id, role, content) VALUES (?, ?, ?)",
                (goal_id, role, content),
            )
    except Exception:
        pass


def get_chat_history(goal_id: int = None, limit: int = 50):
    """Get full chat history, optionally filtered by goal."""
    with get_db() as conn:
        if goal_id:
            cursor = conn.execute(
                "SELECT * FROM chat_messages WHERE goal_id = ? ORDER BY timestamp ASC LIMIT ?",
                (goal_id, limit),
            )
        else:
            cursor = conn.execute(
                "SELECT * FROM chat_messages ORDER BY timestamp ASC LIMIT ?",
                (limit,),
            )
        return [dict(r) for r in cursor.fetchall()]
