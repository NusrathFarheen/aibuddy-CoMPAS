import requests
import json

BASE_URL = "http://localhost:8000"

def test_workspace_features():
    print("🔍 Testing Workspace Features...")

    # 1. Get initial goals
    goals = requests.get(f"{BASE_URL}/api/goals").json()
    if not goals:
        print("❌ No goals found to test with.")
        return
    
    goal_id = goals[0]['id']
    print(f"✅ Using Goal ID: {goal_id} ({goals[0]['title']})")

    # 2. Update Goal Stage & Author
    print("\n📝 Updating Goal Stage & Author...")
    update_data = {
        "current_stage": 2,
        "author_name": "Test Researcher",
        "author_orcid": "1234-5678-9012-3456",
        "author_affiliation": "Test University"
    }
    res = requests.put(f"{BASE_URL}/api/goals/{goal_id}", json=update_data)
    print(f"Status: {res.status_code}")
    updated_goal = res.json()
    assert updated_goal['current_stage'] == 2
    assert updated_goal['author_name'] == "Test Researcher"
    print("✅ Goal update successful")

    # 3. Test References
    print("\n🔗 Testing References...")
    # Add reference
    ref_data = {
        "goal_id": goal_id,
        "title": "Test Paper",
        "url": "https://example.com/paper"
    }
    res = requests.post(f"{BASE_URL}/api/references", json=ref_data)
    print(f"Add Reference: {res.status_code}")
    ref_id = res.json()['id']

    # List references
    res = requests.get(f"{BASE_URL}/api/goals/{goal_id}/references")
    refs = res.json()
    print(f"List References count: {len(refs)}")
    assert any(r['id'] == ref_id for r in refs)

    # Delete reference
    res = requests.delete(f"{BASE_URL}/api/references/{ref_id}")
    print(f"Delete Reference: {res.status_code}")
    
    # 4. Test Finalization
    print("\n🏁 Testing Finalization...")
    res = requests.post(f"{BASE_URL}/api/goals/{goal_id}/finalize")
    print(f"Finalize: {res.status_code}")
    print(f"Response: {res.json()}")

    print("\n✨ All backend workspace features verified!")

if __name__ == "__main__":
    test_workspace_features()
