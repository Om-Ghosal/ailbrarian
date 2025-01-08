import chromadb
from chromadb.utils.embedding_functions import OllamaEmbeddingFunction
import numpy as np
import os

from langchain_community.document_loaders import PyPDFLoader
from langchain.schema.document import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_ollama import OllamaEmbeddings

from bookimgsaver import save_images_from_pdf

import re
import sqlite3 as sql


from PyPDF2 import PdfReader, PdfWriter


CHROMA_PATH = 'db'
BOOK_PATH = 'data'

def document_loader(path):
    loader = PyPDFLoader(path)
    pages = loader.load()
    return pages

def split_documents(documents):
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=2000,
        chunk_overlap=0,
        length_function=len,
        is_separator_regex=True,
        separators=["\n\n", "\n", " ", ""]
    )
    return text_splitter.split_documents(
        documents
    )

def calculate_chunk_ids(chunks: list[Document]):
    index = 0
    for chunk in chunks:
        source = chunk.metadata.get('source')
        page = chunk.metadata.get('page')

        chunk_id = f'{source}:{page}:{index}'
        index += 1

        chunk.metadata["id"] = chunk_id

    return chunks

def remove_pages_after_title(input_pdf, output_pdf, title):
    # Read the PDF
    reader = PdfReader(input_pdf)
    writer = PdfWriter()

    # Iterate through pages to find the title
    for i, page in enumerate(reader.pages):
        text = page.extract_text()
        if title in text:
            print(f"Title found on page {i + 1}. Stopping processing.")
            break
        writer.add_page(page)  # Add pages up to the title

    # Save the new PDF
    with open(output_pdf, "wb") as output_file:
        writer.write(output_file)
        
    print(f"Processed PDF saved as: {output_pdf}")

def embedding_adder(id,book_name,author_name):
    """
    Script to add new documents from pdfs to the chromadb database, processing only pages up to the first occurrence of the string 'THE FULL PROJECT GUTENBERG LICENSE' in each pdf.

    The script assumes that the pdfs are located in the 'data' directory, and that the chromadb database is located in the 'db' directory.

    It will create a new document for each page in each pdf, and will add the embeddings of the text in each page to the corresponding document in the chromadb database.

    The id of each document will be of the form 'source:page:index', where 'source' is the name of the pdf file, 'page' is the number of the page, and 'index' is a unique identifier for the document within the pdf.

    The script will print a message for each pdf processed, indicating the number of new documents added to the database.

    The script will also remove the temporary pdfs created in the 'temp' directory after processing.

    Note that the script assumes that the pdfs do not contain any text in the margins, and that the text in each page is separated by blank lines.

    Also note that the script will not add any documents to the database if the same document already exists in the database, in order to avoid duplication of documents.

    """
    image_path = os.path.join('img',f'{id}.jpg')
    ef = OllamaEmbeddingFunction(
    model_name="nomic-embed-text",
    url="http://localhost:11434/api/embeddings",
)
    db = chromadb.PersistentClient(path=CHROMA_PATH)
    collection = db.get_or_create_collection('books')

    # pdf_list = [x for x in os.listdir('data') if '.txt' not in x]
    i = os.path.join(BOOK_PATH,f'{id}.pdf')

    
    input_pdf_path=f'{BOOK_PATH}/{i}'
    output_pdf = i.split('\\')[-1]
    output_pdf_path=f'''toolbox/temp/{output_pdf}'''
    title_to_find = "THE FULL PROJECT GUTENBERG LICENSE"

    remove_pages_after_title(i, output_pdf_path, title_to_find)
    save_images_from_pdf(i, image_path)

    pages = document_loader(output_pdf_path)
    chunks = split_documents(pages)

    chunks_ids = calculate_chunk_ids(chunks)
    existing_chunks = collection.get(where={'source':{ "$in":[f'temp/{i}'] }})
        

    new_chunks = []
        
    if len(existing_chunks['ids']) == 0:
            for ind,chunk in enumerate(chunks_ids):
                new_chunks.append(chunk)

    consistent_metadata = {
                "book_name": book_name,
                "author_name": author_name,
                "image_path": image_path
            }
        
    if new_chunks and len(new_chunks) > 0:
                print(f"👉 Adding new documents: {len(new_chunks)}")
                metadata = [{**chunk.metadata, **consistent_metadata} for chunk in new_chunks]
                new_chunk_ids = [chunk.metadata['id'] for chunk in new_chunks]

                embeddings = [ef(chunk.page_content) for chunk in new_chunks]

                cleaned_embeddings = [embedding.tolist() if isinstance(embedding, np.ndarray) else embedding for sublist in embeddings for embedding in sublist]

                collection.add(new_chunk_ids,embeddings=cleaned_embeddings,documents=[chunk.page_content for chunk in new_chunks],metadatas=metadata)
                # collection.add()
                print("done!")
    else:
                print("✅ No new documents to add")
            
    os.remove(output_pdf_path)

if __name__ == "__main__":
    connection = sql.connect('E:\my work/ai agents notebook\db/books.db')

    cursor = connection.cursor()

    ids_to_fetch = [i.split('.')[0] for i in os.listdir('data') if '.pdf' in i]


    for id_to_fetch in ids_to_fetch:
        cursor.execute("SELECT * FROM books WHERE id = ?", (id_to_fetch,))
        result = cursor.fetchone()
        if result:
            print("Record found:", result)
            embedding_adder(result[0],result[1],result[2])
        else:
            print(f"No record found with ID: {id_to_fetch}")
        
    connection.commit()
    connection.close()
