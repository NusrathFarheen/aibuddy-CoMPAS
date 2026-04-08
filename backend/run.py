"""
AIBuddy (CoM-PAS) — Backend Entry Point
Run this from the project root: python backend/run.py
"""

import uvicorn
import os
import sys

# Fix Windows console encoding
os.environ["PYTHONIOENCODING"] = "utf-8"
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Add project root to path so imports work
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

if __name__ == "__main__":
    print("=" * 50)
    print("  AIBuddy (CoM-PAS) Backend")
    print("  Cognitive Management & Proactive Assistance")
    print("=" * 50)
    
    port = int(os.environ.get("PORT", 10000))
    debug = os.environ.get("DEBUG", "false").lower() == "true"
    
    uvicorn.run(
        "backend.app.main:app",
        host="0.0.0.0",
        port=port,
        reload=debug,
    )
