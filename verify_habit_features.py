import requests
import json
from datetime import date, timedelta
import sys

# Ensure UTF-8 output
if sys.stdout.encoding != 'UTF-8':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = "http://localhost:8000"

def test_habit_features():
    print("🔍 Testing Habit Features...")

    # 1. Get initial routines
    try:
        res = requests.get(f"{BASE_URL}/api/routines")
        res.raise_for_status()
        routines = res.json()
    except Exception as e:
        print(f"❌ Error fetching routines: {e}")
        return

    if not routines:
        print("❌ No routines found to test with.")
        return
    
    habit = routines[0]
    habit_id = habit['id']
    print(f"✅ Using Habit: {habit['title']} (ID: {habit_id})")

    # 2. Toggle ON
    print("\n🔘 Toggling ON...")
    res = requests.put(f"{BASE_URL}/api/routines/{habit_id}/complete")
    result = res.json()
    print(f"Status: {res.status_code}")
    print(f"is_completed: {result['is_completed']}, Streak: {result['current_streak']}")
    assert result['is_completed'] == 1

    # 3. Toggle OFF (on the same day)
    print("\n🔘 Toggling OFF...")
    res = requests.put(f"{BASE_URL}/api/routines/{habit_id}/complete")
    result = res.json()
    print(f"Status: {res.status_code}")
    print(f"is_completed: {result['is_completed']}, Streak: {result['current_streak']}")
    assert result['is_completed'] == 0

    # 4. Toggle back ON
    print("\n🔘 Toggling back ON...")
    res = requests.put(f"{BASE_URL}/api/routines/{habit_id}/complete")
    result = res.json()
    print(f"is_completed: {result['is_completed']}, Streak: {result['current_streak']}")
    assert result['is_completed'] == 1

    print("\n✨ All habit toggle features verified!")

if __name__ == "__main__":
    test_habit_features()
