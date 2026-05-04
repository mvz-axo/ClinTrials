# Infrastructure

## Current Setup

| Component | Technology | Location | Status |
|---|---|---|---|
| Editor | Zed 1.0.1 | Local | ✅ Running |
| Version control | Git + GitHub | Local + cloud | ✅ Active |
| AI agents | Cline 2.18.0, Kilocode 7.2.34 | Local (Zed) | ✅ Active |
| LLM | Claude Sonnet 4.6 via zed.dev | Cloud | ✅ Active |
| Vector DB | Qdrant (local file mode) | Local | 🔲 To install |
| Graph DB | Neo4j | Local | 🔲 To install |
| Biomedical MCP | BioMCP | Local | 🔲 To install |

## Installation Priorities

1. **BioMCP** — enables immediate literature + trial search
   `pip install biomcp-cli`

2. **Qdrant (local mode)** — enables semantic search without Docker
   `pip install uv`  (mcp-server-qdrant handles the rest)

3. **Augmented Nature MCP servers** — PubMed, UniProt, ChEMBL
   Install via npm — see `.config/mcp/mcp_registry.json`

4. **Neo4j** — enables knowledge graph (Docker recommended)
   `docker run -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password neo4j`

5. **API Keys** — register for NCBI and BioPortal (both free)

## Compute Notes

- All inference runs via Zed's cloud API (no local GPU needed)
- Local embeddings (all-MiniLM-L6-v2) run on CPU — fast enough for development
- Qdrant runs locally with no server process in file mode
