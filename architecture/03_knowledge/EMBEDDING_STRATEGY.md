# Embedding Strategy

## Policy

All embedding models are **open-weight, run locally via Ollama or sentence-transformers**.
No proprietary embedding APIs are used.

## Model Selection

| Use case | Model | Dimensions | Pull command | Quality |
|---|---|---|---|---|
| Zero-friction start | all-MiniLM-L6-v2 | 384 | Built into Qdrant fastembed | Good |
| Recommended default | nomic-embed-text | 768 | `ollama pull nomic-embed-text` | Very good |
| Highest quality | mxbai-embed-large | 1024 | `ollama pull mxbai-embed-large` | Excellent |
| Multilingual | bge-m3 | 1024 | `ollama pull bge-m3` | Excellent |
| Scientific multilingual | qwen3-embedding | 2048 | `ollama pull qwen3-embedding` | Excellent |

## Chunking Strategy

| Content | Chunk size | Overlap | Strategy |
|---|---|---|---|
| Research papers | 512 tokens | 50 | Section-aware (Abstract / Methods / Results / Discussion) |
| Book chapters | 1024 tokens | 100 | Paragraph-aware |
| Notes & summaries | Whole document | — | No chunking |
| Agent conversations | 256 tokens | 25 | Turn-aware |
| Knowledge graph nodes | Whole node | — | No chunking |

## Collections (Qdrant)

See `.config/databases/qdrant.yaml` for collection definitions.
All collections use `nomic-embed-text` (768d) by default.
Change `vector_size` if switching to a different model.

## Retrieval Pipeline

1. Query embedded with same model as corpus
2. Qdrant returns top-k by cosine similarity
3. Results re-ranked by recency + citation count where available
4. Top results passed to Claude as RAG context
5. Claude cites chunk sources in response

## Quickstart

```bash
# Pull the recommended default embedding model
ollama pull nomic-embed-text

# Test it
curl http://localhost:11434/api/embed -d \'{
  "model": "nomic-embed-text",
  "input": "monoclonal antibody epitope binding"
}\'
```
