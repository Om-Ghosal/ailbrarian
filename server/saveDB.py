import sqlite3 as sql
import uuid
import os

def rename_pdfs(old_name,new_name):
    os.rename(old_name,new_name)

id = str(uuid.uuid4())

bookpath = 'data\pg6761-images-3.pdf'
book_name = 'The Adventures of Ferdinand Count Fathom'
author_name = 'T. Smollett'

rename_pdfs(bookpath,f'data/{id}.pdf')


connection = sql.connect('db/books.db')

cursor = connection.cursor()
cursor.execute('''INSERT INTO books (id,book_name,author_name) VALUES (?,?,?)''',(id,book_name,author_name))
print(cursor.execute('select * from books').fetchall())

connection.commit()
connection.close()