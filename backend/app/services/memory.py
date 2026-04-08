"""
H-MACE (Hierarchical Memory) — Semantic Memory System
Supports both local ChromaDB (default) and cloud Pinecone (if PINECONE_API_KEY is set).
"""

import os
import uuid

WORKSPACES = ["research_workspace", "wellness_workspace", "task_workspace"]

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME", "aibuddy")

_use_pinecone = bool(PINECONE_API_KEY)

# ============================================================================
# CHROMA LOCAL IMPLEMENTATION (Default)
# ============================================================================
if not _use_pinecone:
    import chromadb
    CHROMA_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "chroma_db")
    _client = None
    _collections = {}

    def init_memory():
        global _client, _collections
        _client = chromadb.PersistentClient(path=CHROMA_PATH)
        for ws in WORKSPACES:
            _collections[ws] = _client.get_or_create_collection(
                name=ws, metadata={"hnsw:space": "cosine"}
            )
        print(f"✅ H-MACE (ChromaDB) Memory initialized at: {CHROMA_PATH}")
        for ws in WORKSPACES:
            print(f"   📦 {ws}: {_collections[ws].count()} memories")

    def store_memory(workspace: str, text: str, metadata: dict = None, doc_id: str = None):
        if workspace not in _collections:
            raise ValueError(f"Unknown workspace: {workspace}")
        collection = _collections[workspace]
        if doc_id is None:
            doc_id = str(uuid.uuid4())
        
        md = metadata or {}
        # Ensure metadata is pure (Chroma doesn't like nested dicts or non-str/int/float)
        md = {k: str(v) for k, v in md.items()}

        collection.add(documents=[text], ids=[doc_id], metadatas=[md] if md else None)
        return doc_id

    def search_memory(workspace: str, query: str, n_results: int = 5):
        if workspace not in _collections:
            raise ValueError(f"Unknown workspace: {workspace}")
        collection = _collections[workspace]
        if collection.count() == 0:
            return []
        
        results = collection.query(query_texts=[query], n_results=min(n_results, collection.count()))
        memories = []
        if results and results["documents"]:
            for i, doc in enumerate(results["documents"][0]):
                memories.append({
                    "id": results["ids"][0][i],
                    "document": doc,
                    "metadata": results["metadatas"][0][i] if (results.get("metadatas") and results["metadatas"][0]) else {},
                    "distance": results["distances"][0][i] if results.get("distances") else None,
                })
        return memories

    def get_workspace_stats():
        return {ws: _collections[ws].count() for ws in WORKSPACES if ws in _collections}

# ============================================================================
# PINECONE CLOUD IMPLEMENTATION (Fallback for Production)
# ============================================================================
else:
    from pinecone import Pinecone
    from chromadb.utils.embedding_functions import DefaultEmbeddingFunction

    _pc = None
    _index = None
    _ef = DefaultEmbeddingFunction()

    def init_memory():
        global _pc, _index
        _pc = Pinecone(api_key=PINECONE_API_KEY)
        # Verify index exists
        if PINECONE_INDEX_NAME not in [i.name for i in _pc.list_indexes()]:
            print(f"⚠️ Pinecone index '{PINECONE_INDEX_NAME}' not found! Please create it with 384 dimensions.")
        else:
            _index = _pc.Index(PINECONE_INDEX_NAME)
            print(f"✅ H-MACE (Pinecone) Memory initialized on index: {PINECONE_INDEX_NAME}")

    def store_memory(workspace: str, text: str, metadata: dict = None, doc_id: str = None):
        if workspace not in WORKSPACES:
            raise ValueError(f"Unknown workspace: {workspace}")
        
        if _index is None:
            return None # Fail gracefully if index not created yet
            
        if doc_id is None:
            doc_id = str(uuid.uuid4())
            
        # Generate embedding
        vector = _ef([text])[0]
        
        md = metadata or {}
        md["workspace"] = workspace
        md["text"] = text  # Store text in metadata so we can retrieve it
        md = {k: str(v) for k, v in md.items()}
        
        _index.upsert(vectors=[{"id": doc_id, "values": vector, "metadata": md}])
        return doc_id

    def search_memory(workspace: str, query: str, n_results: int = 5):
        if workspace not in WORKSPACES:
            raise ValueError(f"Unknown workspace: {workspace}")
        
        if _index is None:
            return []
            
        vector = _ef([query])[0]
        
        results = _index.query(
            vector=vector,
            filter={"workspace": {"$eq": workspace}},
            top_k=n_results,
            include_metadata=True
        )
        
        memories = []
        for match in results.matches:
            md = match.metadata or {}
            memories.append({
                "id": match.id,
                "document": md.get("text", ""),
                "metadata": {k: v for k, v in md.items() if k not in ["workspace", "text"]},
                "distance": match.score, # Pinecone returns cosine similarity (higher is better). 
            })
        return memories

    def get_workspace_stats():
        if _index is None:
            return {ws: 0 for ws in WORKSPACES}
        try:
            total = _index.describe_index_stats().total_vector_count
            return {ws: total for ws in WORKSPACES} 
        except:
            return {ws: 0 for ws in WORKSPACES}
