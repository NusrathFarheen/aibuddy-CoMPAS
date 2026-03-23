"""
H-MACE (Hierarchical Memory) — ChromaDB Semantic Memory System
Partitioned into Research, Wellness, and Task workspaces for RAG.
"""

import chromadb
import os

# ChromaDB persisted at project root
CHROMA_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "chroma_db")

_client = None
_collections = {}

WORKSPACES = ["research_workspace", "wellness_workspace", "task_workspace"]


def init_memory():
    """Initialize ChromaDB client and create workspace collections."""
    global _client, _collections

    _client = chromadb.PersistentClient(path=CHROMA_PATH)

    for ws in WORKSPACES:
        _collections[ws] = _client.get_or_create_collection(
            name=ws,
            metadata={"hnsw:space": "cosine"}
        )

    print(f"✅ H-MACE Memory initialized at: {CHROMA_PATH}")
    for ws in WORKSPACES:
        count = _collections[ws].count()
        print(f"   📦 {ws}: {count} memories")


def store_memory(workspace: str, text: str, metadata: dict = None, doc_id: str = None):
    """
    Store a memory fragment in the specified workspace.
    
    Args:
        workspace: One of 'research_workspace', 'wellness_workspace', 'task_workspace'
        text: The text content to embed and store
        metadata: Optional metadata dict (e.g., {"source": "journal", "mood": 3})
        doc_id: Optional unique ID. Auto-generated if not provided.
    """
    if workspace not in _collections:
        raise ValueError(f"Unknown workspace: {workspace}. Must be one of {WORKSPACES}")

    collection = _collections[workspace]

    if doc_id is None:
        import uuid
        doc_id = str(uuid.uuid4())

    add_kwargs = {
        "documents": [text],
        "ids": [doc_id],
    }
    if metadata:
        add_kwargs["metadatas"] = [metadata]

    collection.add(**add_kwargs)
    return doc_id


def search_memory(workspace: str, query: str, n_results: int = 5):
    """
    Semantic search across a workspace.
    
    Returns:
        List of dicts with 'id', 'document', 'metadata', and 'distance'.
    """
    if workspace not in _collections:
        raise ValueError(f"Unknown workspace: {workspace}. Must be one of {WORKSPACES}")

    collection = _collections[workspace]

    if collection.count() == 0:
        return []

    results = collection.query(
        query_texts=[query],
        n_results=min(n_results, collection.count())
    )

    memories = []
    if results and results["documents"]:
        for i, doc in enumerate(results["documents"][0]):
            memories.append({
                "id": results["ids"][0][i],
                "document": doc,
                "metadata": results["metadatas"][0][i] if results["metadatas"] else {},
                "distance": results["distances"][0][i] if results["distances"] else None,
            })

    return memories


def get_workspace_stats():
    """Return memory counts per workspace."""
    return {ws: _collections[ws].count() for ws in WORKSPACES if ws in _collections}
