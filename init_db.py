import sqlite3
 
conn = sqlite3.connect('soccer.db')
 
with open('schema.sql') as f:
    conn.executescript(f.read())
 
conn.close()
print("done")