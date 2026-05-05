# mvz-axo Research Platform — Onboarding

## Setting Up a Research Repository from Scratch

### Prerequisites (already installed on this machine)

| Tool | Version | Purpose |
|------|---------|---------|
| Rust + Cargo | stable 1.85+ | Compiling domain crates + arsenal servers |
| Ollama | 0.23+ | Local LLM runtime (GPU-accelerated) |
| Qdrant | running :6333 | Vector database for semantic search |
| Unsloth Studio | 2026.4+ | Local model training + inference UI |
| Node.js + npm | 20+ | Augmented Nature MCP servers |
| uv | 0.11+ | Python tool installation (BioMCP) |
| Git | — | Version control |

### Step 1 — Clone and Configure (5 min)

```bash
git clone git@github.com:mvz-axo/<ProjectName>.git ~/Clones/<ProjectName>
cd ~/Clones/<ProjectName>
cp .env.example .env
# Edit .env — fill in API keys (see priority order in .env.example header)
```

### Step 2 — Install API Keys (10–20 min, mostly waiting for emails)

Follow the **PRIORITY ORDER** at the top of `.env.example`. Start with:
1. NCBI_API_KEY — 2 min, instant
2. BIOPORTAL_API_KEY — 2 min, instant
3. ANTHROPIC_API_KEY — 5 min, requires billing setup
4. BRAVE_API_KEY — 2 min, free tier requires no credit card
5. GITHUB_TOKEN — 2 min

### Step 3 — Install BioMCP (2 min)

```bash
uv tool install biomcp-cli
biomcp --version
biomcp health --apis-only
```

### Step 4 — Install Augmented Nature MCP Servers (10 min)

```bash
for server in pubmed uniprot chembl ncbi biothings bioontology; do
  git clone https://github.com/Augmented-Nature/${server}-mcp-server \
    ~/.mcp-servers/${server}
  cd ~/.mcp-servers/${server} && npm install && npm run build && cd -
done
```

### Step 5 — Activate in Zed

Copy `zed_config` blocks from `.config/mcp/mcp_registry.json` into
`~/.config/zed/settings.json` under `"context_servers"`.

At minimum, activate: `biomcp`, `arsenal-embedding`, `arsenal-logseq`,
`brave-search`, `sequential-thinking`.

### Step 6 — Pull an Embedding Model

```bash
ollama pull nomic-embed-text    # Already loaded — skip if present
ollama list                     # Verify
```

### Step 7 — Build the Domain MCP Server

```bash
cd ~/Clones/<ProjectName>
cargo build --release -p <domain>-mcp
# Binary appears at: target/release/<domain>-mcp
```

### Step 8 — Start a Research Session

```bash
# Check services
ollama list
curl -s http://localhost:6333/collections | jq .
systemctl --user status unsloth-studio

# Open your first research question in Zed
# Use BioMCP to start: biomcp search article -k "<your question>" --limit 5
```

## Daily Workflow

```
Morning
  ├─ Review RSS feeds (arsenal-mcp-rss-reader)
  ├─ Check HYPOTHESIS_LOG.md and RESEARCH_PLAN.md
  └─ Run any overnight experiments

Research session
  ├─ Agent searches literature (BioMCP + PubMed MCP)
  ├─ Embed new papers (arsenal-mcp-embedding)
  ├─ Query knowledge graph (Logseq MCP + Neo4j MCP)
  ├─ Generate hypotheses (agent persona)
  └─ Log findings → HYPOTHESIS_LOG.md

Evening
  ├─ Update CHANGELOG.md
  └─ Commit all tracked files (data/ bulk is gitignored)
```

## Kask Repository (Shared Substrate)

The `~/Clones/kask/` repository provides the Rust substrate:
- `kask/stack/` — MCP protocol, LLM routing, bitemporal store, memory
- `kask/arsenal/` — pre-built MCP servers (embedding, RSS, logseq, etc.)

To rebuild arsenal binaries after kask updates:
```bash
cd ~/Clones/kask
git pull
cd arsenal
cargo build --release -p arsenal-mcp-embedding \
                       -p arsenal-mcp-rss-reader \
                       -p arsenal-mcp-logseq
cp target/release/arsenal-mcp-{embedding,rss-reader,logseq} ~/.local/bin/
```

## Unsloth Studio

Fine-tune models on your RTX 5070 Ti (12GB VRAM):
- Access: http://192.168.18.47:8888 (LAN) or http://localhost:8888 (local)
- Service: `systemctl --user status unsloth-studio`
- Supports: SFT, DPO, LoRA, QLoRA on Llama, Qwen, Gemma, Mistral, and more

For large training runs (>12GB VRAM): configure RUNPOD_API_KEY and use cloud GPU.
