from fastapi import FastAPI, HTTPException,Query
from pydantic import BaseModel
from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.document_loaders import PyPDFLoader
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_groq import ChatGroq
import os
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app = FastAPI()


# Load and process the document
loader = PyPDFLoader("budget_speech.pdf")  # Adjust the path to your PDF file
documents = loader.load()

text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
docs = text_splitter.split_documents(documents)

# Initialize embeddings and FAISS
embeddings = HuggingFaceEmbeddings()
docsearch = FAISS.from_documents(docs, embeddings)

# Set up the Groq API key
os.environ["GROQ_API_KEY"] = "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"

# Initialize the language model and QA chain
llm = ChatGroq(model="Llama-3.1-70b-versatile", temperature=0)
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=docsearch.as_retriever(),
    return_source_documents=True,
)

# Define request model
class QueryRequest(BaseModel):
    query: str

# Define FastAPI endpoints
@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI application"}

@app.get("/favicon.ico")
async def favicon():
    return FileResponse("static/favicon.ico")  # Ensure you have this file
# Define FastAPI endpoint
# @app.get("/query/")
# async def query_document(request: QueryRequest):
#     try:
#         # Use the QA chain to get an answer
#         response = qa_chain.invoke(request.query)
#         return {"query": request.query, "answer": response['result'], "source_documents": response['source_documents']}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/query/")
async def query_document(query: str = Query(...)):
    try:
        # Use the QA chain to get an answer
        response = qa_chain.invoke(query)
        return {"query": query, "answer": response['result'], "source_documents": response['source_documents']}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run the API with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
