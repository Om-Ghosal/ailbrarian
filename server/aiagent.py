from langchain_ollama import ChatOllama
from langchain_core.messages import HumanMessage,SystemMessage,AIMessage

from langgraph.prebuilt import create_react_agent

from toolbox.overview_maker import overview_maker,book_checker
from langgraph.prebuilt import create_react_agent

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel,RootModel
from fastapi.middleware.cors import CORSMiddleware
from typing import Dict,List
from fastapi.responses import FileResponse,JSONResponse,Response

import os
import sqlite3 as sql
import base64
import json

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace "*" with the specific origin if needed
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define a nested model for "user" and "text"
class Message(BaseModel):
    name: str
    content:str
class Chathistory(BaseModel):
    index: str
    msg:Message # Arbitrary string keys mapping to Message objects # Allows arbitrary string keys mapping to Message

@app.post('/aiagent')
def aiagent(message: List[Chathistory]):
    model = ChatOllama(model='mistral:latest')

    tools = [overview_maker,book_checker]

    agent_executor = create_react_agent(model=model, tools=tools)
    messages = [SystemMessage(content="You are a helpful librarian giving helpful insights about books to people."),
        ]
    for msg in message:
        if msg.msg.name == 'leor':
            messages.append(HumanMessage(content=msg.msg.content))
        else:
            messages.append(AIMessage(content=msg.msg.content))

    print('messages:\n',messages)

    print('creating response:\n')
    response = agent_executor.invoke(
        {"messages": messages}
    )
    print('response:\n')
    return str(response["messages"][-1].content).replace('\n','').replace('*','')

@app.get('/fetchbooks')
def fetchbooks():
    connection = sql.connect('db/books.db')
    cursor = connection.cursor()
    list_books = cursor.execute('select * from books').fetchall()
    connection.commit()
    connection.close()

    book_images_list = []
    for i in list_books:
        books_images={}
        books_images['id']=i[0]
        books_images['book_name']=i[1]
        books_images['author_name']=i[2]
        book_images_list.append(books_images)

    return book_images_list

# 732c3b4f-0b26-46cd-bd3b-430da5efdb46
@app.post(
    "/image",

    # Set what the media type will 
    # fastapi.tiangolo.com/advanced/additional-responses/#additional-media-types-for-the-main-response
    responses = {
        200: {
            "content": {"image/jpeg": {}}
        }
    },

    # Prevent FastAPI from adding "application/json" as an additional
    # response media type
    # https://github.com/tiangolo/fastapi/issues/3258
    response_class=Response
)
def get_image(book_id):

    image_path = 'img/'+book_id+'.jpg'

    try:
        return FileResponse(image_path,media_type='image/jpeg')
    except Exception  as e:
        return JSONResponse(content={'error': e})

@app.post('/getbook',responses={200:{"content":{"application/pdf":{}}}},response_class=Response)
def getbook(book_id):
    book_path = 'data/'+book_id+'.pdf'
    try:
        return FileResponse(book_path)
    except Exception  as e:
        return JSONResponse(content={'error': e})


    
    



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.0.157", port=8000)