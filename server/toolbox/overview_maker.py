import chromadb
from chromadb.utils.embedding_functions import OllamaEmbeddingFunction
import numpy as np
import os

from langchain_ollama import ChatOllama
from langchain.schema.document import Document

from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool

CHROMA_PATH = 'db'
BOOK_PATH = 'data'

def book_overview(context,llm):
    reduce_template = """
The following is a set of summaries:
{context}
Take these and distill it into a final, consolidated summary
of the main themes.
"""

    reduce_prompt = ChatPromptTemplate([("human", reduce_template)])

    
    
    chain = create_stuff_documents_chain(llm, reduce_prompt)
    result = chain.invoke({"context": context})
    return result
        
@tool()
def overview_maker(book_name:str):
    """
    A tool that generates a summary or an overview of a book.

    Args:
        book_name (str): The name of the book.

    Returns:
        str: The summary or overview of the book.
    """
    book_name = book_name.lower()
    
    db = chromadb.PersistentClient(path=CHROMA_PATH)
    collection = db.get_or_create_collection("books")

    book_ids = collection.get()['ids']
    book_docs = collection.get()['documents']
    book_metadata = collection.get()['metadatas']

    document_list = [book_docs[i] for i in range(len(book_ids)) if book_name in book_metadata[i]['book_name']]
    print(document_list)


    document_list = [Document(page_content=text) for text in document_list]
    

    llm = ChatOllama(model='mistral:latest')
    return book_overview(document_list,llm)

@tool()
def book_checker():
    """
    A tool that returns a list of all book pdfs present in the database

    Args:
        None

    Returns:
        list: The list of all books present in the database.
    """
    return os.listdir(BOOK_PATH)

if __name__ == "__main__":
    print(overview_maker("greasy luck"))