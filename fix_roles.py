import sqlite3

c = sqlite3.connect('planner.db')
c.execute("UPDATE chat_messages SET role = 'assistant' WHERE role = 'ai'")
c.execute("UPDATE chat_messages SET role = 'system' WHERE role NOT IN ('assistant', 'user', 'system')")
c.commit()
print("Chat database roles fixed.")
