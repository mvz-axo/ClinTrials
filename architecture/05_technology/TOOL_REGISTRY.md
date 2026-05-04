# Tool Registry

## MCP Server Access Requirements

Full configs in `.config/mcp/mcp_registry.json`

| Server | Access Required | Install method | Status |
|---|---|---|---|
| **BioMCP** | None | `uv tool install biomcp-cli` | 🔲 Install needed |
| **PubMed MCP** | Optional: NCBI_API_KEY | npm (Augmented Nature) | 🔲 Install needed |
| **UniProt MCP** | None | npm (Augmented Nature) | 🔲 Install needed |
| **ChEMBL MCP** | None | npm (Augmented Nature) | 🔲 Install needed |
| **NCBI Datasets MCP** | Optional: NCBI_API_KEY | npm (Augmented Nature) | 🔲 Install needed |
| **BioThings MCP** | None | npm (Augmented Nature) | 🔲 Install needed |
| **BioOntology MCP** | **Required: BIOPORTAL_API_KEY** | npm (Augmented Nature) | 🔲 Install needed |
| **Qdrant MCP** | None (local file mode) | uv already installed ✅ | 🔲 Configure |
| **Neo4j MCP** | Neo4j DB running | Binary from GitHub | 🔲 Install needed |
| **Memory MCP** | None | npx (auto, Node.js ✅) | 🔲 Configure |
| **Filesystem MCP** | None | npx (auto, Node.js ✅) | 🔲 Configure |
| **GitHub MCP** | GITHUB_TOKEN | Zed extension ✅ | ✅ Active |
| **Sequential Thinking** | None | Zed extension ✅ | ✅ Active |

## Free API Keys to Register (takes 2 min each)

| Service | URL | Why |
|---|---|---|
| NCBI | https://www.ncbi.nlm.nih.gov/account | 10x higher rate limits for BioMCP + NCBI MCP |
| BioPortal | https://bioportal.bioontology.org/accounts/new | **Required** for BioOntology MCP |
| HuggingFace | https://huggingface.co/settings/tokens | Required for gated models (MedGemma) |

## Python/uv Packages

```bash
# Use uv (already installed) instead of pip
uv tool install biomcp-cli          # BioMCP CLI
uv pip install qdrant-client        # Qdrant Python client
uv pip install sentence-transformers # Fallback local embeddings
uv pip install biopython            # Bioinformatics utilities
uv pip install pandas numpy scipy   # Data analysis
uv pip install matplotlib plotly    # Visualisation
uv pip install py2neo               # Neo4j Python client
uv pip install requests httpx       # API access
uv pip install jupyter              # Notebooks
uv pip install ollama               # Ollama Python client
```

## Open-Weight LLMs (via Ollama — already installed)

```bash
# Medical models
ollama pull meditron:7b             # Immediate, 3.8GB — fast medical QA
ollama pull meditron:70b            # 39GB — best open medical reasoning
ollama pull medgemma                # MedGemma 4B — multimodal (needs HF token)

# General open-weight models
ollama pull qwen2.5:14b             # 9GB — strong science/biomedical reasoning
ollama pull qwen2.5:32b             # 20GB — deeper reasoning
ollama pull glm4                    # 6GB — bilingual, 128K context
ollama pull phi4                    # 9GB — strong reasoning, MIT license
ollama pull kimi-k2.5               # Long context specialist

# Embedding models (pick one to start)
ollama pull nomic-embed-text        # ← recommended default
ollama pull mxbai-embed-large       # Higher quality
ollama pull bge-m3                  # Best multilingual
```

## Zed Extensions (installed)

| Extension | Purpose |
|---|---|
| Cline 2.18.0 | AI coding agent with full file access |
| Kilocode 7.2.34 | AI coding agent |
| dockerfile | Docker file support |
