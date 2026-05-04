# Embedding Strategy

## Model Selection

| Use case | Model | Dimensions | Provider | API key |
|---|---|---|---|---|
| Development / offline | all-MiniLM-L6-v2 | 384 | sentence-transformers | None |
| Production literature | text-embedding-3-large | 3072 | OpenAI | ✅ |
| Production (budget) | text-embedding-3-small | 1536 | OpenAI | ✅ |

## Chunking Strategy

| Content | Chunk size | Overlap | Strategy |
|---|---|---|---|
| Research papers | 512 tokens | 50 | Section-aware (Abstract, Methods, Results, Discussion) |
| Book chapters | 1024 tokens | 100 | Paragraph-aware |
| Notes & summaries | Whole document | — | No chunking |
| Agent conversations | 256 tokens | 25 | Turn-aware |

## Collections (Qdrant)

See `.config/databases/qdrant.yaml` for collection definitions.

## Retrieval Pipeline

1. Query embedded with same model as corpus
2. Qdrant returns top-k by cosine similarity
3. Results re-ranked by recency + citation count (where available)
4. Top results passed to LLM as RAG context
5. LLM cites chunk sources in response

## Recommended starting point

Use **all-MiniLM-L6-v2 via fastembed** (built into mcp-server-qdrant) — no API key,
runs locally, good quality for development. Upgrade to text-embedding-3-large
when building production literature corpora.
