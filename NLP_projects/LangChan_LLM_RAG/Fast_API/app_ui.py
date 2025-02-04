from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.templating import Jinja2Templates
from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain.document_loaders import PyPDFLoader
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_groq import ChatGroq
import os
from starlette.requests import Request

app = FastAPI()
templates = Jinja2Templates(directory="templates")

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

# Define FastAPI endpoints
@app.get("/", response_class=HTMLResponse)
def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/query/", response_class=HTMLResponse)
async def query_document(request: Request, query: str = Query(...)):
    try:
        # Use the QA chain to get an answer
        response = qa_chain.invoke(query)
        return templates.TemplateResponse("result.html", {
            "request": request,
            "query": query,
            "answer": response['result']
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/favicon.ico")
async def favicon():
    return FileResponse("static/favicon.ico")  # Ensure you have this file

# Run the API with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
