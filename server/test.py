import sqlite3 as sql

connection = sql.connect('db/books.db')

cursor = connection.cursor()

print(cursor.execute("SELECT * FROM books").fetchall())