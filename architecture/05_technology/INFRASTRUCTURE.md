# Infrastructure

## Current Setup

| Component | Technology | Version | Status |
|---|---|---|---|
| Editor | Zed | 1.0.1 | ✅ Running |
| Version control | Git + GitHub | — | ✅ Active |
| AI agents | Cline + Kilocode | 2.18 / 7.2.34 | ✅ Active |
| Primary LLM | Claude Sonnet 4.6 via zed.dev | — | ✅ Active |
| Local LLM runtime | Ollama | 0.23.0 | ✅ Installed |
| Python runtime | Python | 3.13.7 | ✅ Installed |
| Package manager | uv | 0.11.8 | ✅ Installed |
| Node.js | Node.js + npm | 20.19.4 / 9.2.0 | ✅ Installed |
| Vector DB | Qdrant (local file mode) | — | 🔲 Configure |
| Graph DB | Neo4j | — | 🔲 To install |
| Biomedical MCP | BioMCP | — | 🔲 To install |

## LLM Policy

- **Anthropic Claude** — primary reasoning model (via Zed cloud API)
- **Open-weight models via Ollama** — medical specialised + general capability
- **No other closed proprietary models** — no OpenAI, no Gemini API, no Cohere

## Installation Priorities

### Step 1 — BioMCP (5 min, no keys needed)
```bash
uv tool install biomcp-cli
biomcp --version
biomcp health --apis-only
```

### Step 2 — First local medical model (5 min)
```bash
ollama pull meditron:7b             # 3.8GB — immediate medical QA capability
ollama pull nomic-embed-text        # Default embedding model
```

### Step 3 — Get free API keys (5 min)
- NCBI: https://www.ncbi.nlm.nih.gov/account
- BioPortal: https://bioportal.bioontology.org/accounts/new
- HuggingFace: https://huggingface.co/settings/tokens (for MedGemma)

### Step 4 — Augmented Nature MCP servers (npm, Node.js already installed)
```bash
git clone https://github.com/Augmented-Nature/PubMed-MCP-Server ~/.mcp-servers/pubmed
cd ~/.mcp-servers/pubmed && npm install && npm run build
# Repeat for uniprot, chembl, ncbi, biothings, bioontology
# See .config/mcp/mcp_registry.json for all install commands
```

### Step 5 — Qdrant (already have uv, no Docker needed)
```bash
# mcp-server-qdrant via uvx handles this automatically
# Just add to Zed settings.json — see MCP_ARCHITECTURE.md
```

### Step 6 — Neo4j (when ready for knowledge graphs)
```bash
docker run -d --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/yourpassword \
  -e NEO4J_PLUGINS='["apoc"]' neo4j
```

## Compute Notes

- Claude runs via Zed cloud — no local GPU required for primary reasoning
- Ollama runs open-weight models on CPU (slow but functional) or GPU (fast)
- Qdrant in local file mode — no server process, no Docker, zero overhead
- All npm MCP servers are already supported (Node.js 20 installed)
