# Tool Registry — mvz-axo Research Platform

Full MCP server configuration in `.config/mcp/mcp_registry.json`.
Platform architecture: `architecture/00_platform/MCP_LAYER.md`.

## MCP Servers — Status Overview

### ✅ Active (no further action needed)

| Server | What it does | Key |
|--------|-------------|-----|
| **BioMCP** | ClinicalTrials, PubMed, genes, variants, drugs, diseases, pathways (30+ tools) | None |
| **arsenal-mcp-embedding** | PDF/MD → chunk → embed → Qdrant; semantic search (7 tools) | Uses QDRANT_URL + OLLAMA_BASE_URL |
| **arsenal-mcp-rss-reader** | RSS/Atom/JSON feed reader, folder management (19 tools) | None |
| **arsenal-mcp-logseq** | Logseq knowledge graph CRUD — pages, blocks, backlinks (8 tools) | None |
| **GitHub MCP** | Repos, issues, PRs, code search | GITHUB_TOKEN |
| **Sequential Thinking** | Structured multi-step reasoning | None |

### 🔲 Install needed (npm — Node.js already installed)

```bash
# Install all Augmented Nature biomedical MCP servers at once:
for server in PubMed-MCP-Server UniProt-MCP-Server ChEMBL-MCP-Server \
              NCBI-Datasets-MCP-Server BioThings-MCP-Server BioOntology-MCP-Server; do
  repo=$(echo $server | tr '[:upper:]' '[:lower:]' | tr '-' '_')
  git clone https://github.com/Augmented-Nature/${server} ~/.mcp-servers/${repo}
  cd ~/.mcp-servers/${repo} && npm install && npm run build && cd -
done
```

| Server | Tools | Key required | Notes |
|--------|-------|-------------|-------|
| **PubMed MCP** | 12 | Optional: NCBI_API_KEY | 36M+ citations, MeSH, full text |
| **UniProt MCP** | 15 | None | Protein sequences, domains, structures |
| **ChEMBL MCP** | 18 | None | Drug discovery, ADMET, bioactivity |
| **NCBI Datasets MCP** | 31 | Optional: NCBI_API_KEY | Genomes, genes, taxonomy |
| **BioThings MCP** | 10 | None | MyGene + MyVariant |
| **BioOntology MCP** | 8 | **BIOPORTAL_API_KEY** 🔒 | 1,200+ ontologies |
| **Brave Search MCP** | 2 | **BRAVE_API_KEY** 🔒 | Live web search for agents |
| **Qdrant MCP** | 5 | None (local) | Via `uvx mcp-server-qdrant` |
| **Neo4j MCP** | 10 | Neo4j running | Binary from GitHub releases |
| **Memory MCP** | 6 | None | Via `npx @modelcontextprotocol/server-memory` |
| **Filesystem MCP** | 8 | None | Via `npx @modelcontextprotocol/server-filesystem` |

### Install Brave Search MCP

```bash
# No pre-install needed — npx runs it on demand.
# Add to ~/.config/zed/settings.json → context_servers:
# "brave-search": {
#   "command": "npx",
#   "args": ["-y", "@modelcontextprotocol/server-brave-search"],
#   "env": { "BRAVE_API_KEY": "your-key" }
# }
# Get key (free 2,000 queries/month): https://api.search.brave.com/app/keys
```

## API Keys — Acquisition Checklist

| Key | Where | Cost | Time | Priority |
|-----|-------|------|------|----------|
| NCBI_API_KEY | https://www.ncbi.nlm.nih.gov/account/ | 🆓 Free | 2 min | ⭐⭐⭐ |
| BIOPORTAL_API_KEY | https://bioportal.bioontology.org/accounts/new | 🆓 Free | 2 min | ⭐⭐⭐ |
| ANTHROPIC_API_KEY | https://console.anthropic.com | 💳 Paid | 5 min | ⭐⭐⭐ |
| BRAVE_API_KEY | https://api.search.brave.com/app/keys | 💳 2K free/mo | 2 min | ⭐⭐ |
| GITHUB_TOKEN | https://github.com/settings/tokens | 🆓 Free | 2 min | ⭐⭐ |
| HUGGINGFACE_TOKEN | https://huggingface.co/settings/tokens | 🆓 Free | 2 min | ⭐⭐ |
| S2_API_KEY | https://www.semanticscholar.org/product/api#api-key-form | 🆓 Free | 3 min | ⭐⭐ |
| CROSSREF_MAILTO | Email address only | 🆓 Free | 30 sec | ⭐ |
| OPENALEX_EMAIL | Email address only | 🆓 Free | 30 sec | ⭐ |
| OPENROUTER_API_KEY | https://openrouter.ai/keys | 💳 Paid | 3 min | Optional |
| RUNPOD_API_KEY | https://www.runpod.io/console/user/settings | 💳 Paid | 5 min | Optional |
| DRUGBANK_API_KEY | https://go.drugbank.com/users/sign_up | 🆓 Academic | 24–48h | Optional |
| LENS_API_KEY | https://www.lens.org/lens/user/subscriptions | 🆓 Free | 3 min | Optional |

## Open-Weight LLMs via Ollama

```bash
# Already loaded on this machine:
# medgemma1.5, qwen3.5:9b, gemma4:26b, nomic-embed-text

# Additional models to consider:
ollama pull meditron:7b          # 3.8GB — fast medical QA
ollama pull phi4                 # 9GB  — strong reasoning, MIT license
ollama pull qwen2.5:14b          # 9GB  — strong science reasoning
ollama pull mxbai-embed-large    # 670MB — higher-quality embeddings

# For embedding: use ONE model consistently across all collections
# Current platform standard: nomic-embed-text (768-dim)
```

## Unsloth Studio

Local model fine-tuning and inference UI.
- URL: http://192.168.18.47:8888 (LAN) or http://localhost:8888
- Status: `systemctl --user status unsloth-studio`
- Docs: https://unsloth.ai/docs

Supported training: SFT, DPO, LoRA, QLoRA on Llama, Qwen, Gemma, Mistral, Phi, and more.
Max local model size: ~13B full precision / ~70B with QLoRA on 12GB VRAM.

## Kask Arsenal Binaries

Pre-built Rust MCP servers from `~/Clones/kask/arsenal/`:

```bash
# Rebuild all installed arsenal servers:
cd ~/Clones/kask && git pull
cd arsenal
cargo build --release \
  -p arsenal-mcp-embedding \
  -p arsenal-mcp-rss-reader \
  -p arsenal-mcp-logseq
cp target/release/arsenal-mcp-{embedding,rss-reader,logseq} ~/.local/bin/
```
