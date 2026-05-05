# Infrastructure — mvz-axo Research Platform

## Current Stack

| Component | Technology | Version | Status |
|-----------|-----------|---------|--------|
| **Editor** | Zed | 1.0.1 | ✅ Running |
| **Version control** | Git + GitHub | — | ✅ Active |
| **AI agents** | Cline + Kilocode | 2.18 / 7.2.34 | ✅ Active |
| **Primary LLM** | Claude Sonnet 4.6 (via zed.dev) | — | ✅ Active |
| **Local LLM runtime** | Ollama | 0.23.0 | ✅ GPU-accelerated |
| **GPU** | NVIDIA RTX 5070 Ti Mobile | 12 GB VRAM | ✅ Active |
| **Language** | Rust (stable 1.85, edition 2024) | — | ✅ Active |
| **Rust substrate** | Kask (stack + arsenal) | 0.11.0 | ✅ Cloned at ~/Clones/kask/ |
| **Fine-tuning UI** | Unsloth Studio | 2026.4.8 | ✅ Running :8888 |
| **Vector DB** | Qdrant | — | ✅ Running :6333 (LAN-accessible) |
| **Graph DB** | Neo4j | — | 🔲 Install when needed |
| **Biomedical MCP** | BioMCP | 0.8.22 | ✅ Installed |
| **Document MCP** | arsenal-mcp-embedding | 0.11.0 | ✅ Installed (~/.local/bin/) |
| **RSS MCP** | arsenal-mcp-rss-reader | 0.11.0 | ✅ Installed (~/.local/bin/) |
| **Knowledge MCP** | arsenal-mcp-logseq | 0.11.0 | ✅ Installed (~/.local/bin/) |
| **Web search MCP** | Brave Search MCP | — | 🔲 Needs BRAVE_API_KEY |
| **Package manager** | uv (Python tools) | 0.11.8 | ✅ Installed |
| **Node.js** | Node.js + npm | 20.19.4 / 9.2.0 | ✅ Installed |

## LLM Policy

- **Anthropic Claude** — primary reasoning model (via Zed cloud API + direct API)
- **Open-weight models via Ollama** — domain-specific + general capability, GPU-accelerated
- **No other closed proprietary models** — no OpenAI GPT, no Gemini API, no Cohere
- **OpenRouter** — optional gateway for model comparison and frontier model access

## Currently Loaded Ollama Models

```bash
ollama list   # Current state:
# medgemma1.5:latest    — Google MedGemma 1.5B (medical Q&A)
# qwen3.5:9b            — Strong science reasoning
# gemma4:26b            — Multimodal, 26B parameters
# nomic-embed-text      — Embedding model (768-dim, used by arsenal-mcp-embedding)
```

## Kask Substrate

The [kask repository](https://github.com/Replicant-Partners/kask) provides the Rust
substrate for all research tooling on this platform:

- `kask/stack/` — Core libraries: MCP protocol, LLM routing, bitemporal store, vector
  store abstractions, settings, auth, clock, CRDT
- `kask/arsenal/` — MCP tool servers: embedding pipeline, RSS reader, Logseq, inference,
  teaching engine, knowledge extraction, and more

Cloned at: `~/Clones/kask/`
Arsenal binaries installed at: `~/.local/bin/arsenal-mcp-{embedding,rss-reader,logseq}`
Rebuild: `cd ~/Clones/kask/arsenal && cargo build --release -p <name>`

## Rust Workspace

Each research repository is a Cargo workspace (`Cargo.toml` at root).
Domain crates live in `crates/` and follow the pattern:

| Crate role | Purpose |
|-----------|---------|
| `<domain>-core` | Strongly-typed domain model (no I/O, pure types) |
| `<domain>-ingest` | Async API clients for external data sources |
| `<domain>-mcp` | Custom MCP tool server binary for this domain |
| `<domain>-cli` | Research CLI for running pipelines from the terminal |

See `architecture/00_platform/RUST_WORKSPACE.md` for the full workspace guide.

## Service Status

```bash
# Check all platform services
ollama list                                          # Loaded models
curl -s http://localhost:6333/collections | jq .    # Qdrant collections
systemctl --user status unsloth-studio              # Unsloth Studio
systemctl --user status ollama                      # Ollama daemon

# Test arsenal MCP servers
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' \
  | ~/.local/bin/arsenal-mcp-embedding 2>/dev/null | head -5
```

## Neo4j Setup (when ready)

```bash
docker run -d --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/yourpassword \
  -e NEO4J_PLUGINS='["apoc"]' \
  neo4j:community
# Browser UI: http://localhost:7474
# Bolt URI:   bolt://localhost:7687
```

## Compute Notes

- Claude: Zed cloud — no local GPU needed for primary reasoning
- Ollama: all models run on RTX 5070 Ti (12GB VRAM) — fast inference
- Qdrant: local file mode — no server process, zero Docker overhead
- Unsloth Studio: RTX 5070 Ti — supports models up to ~7–13B at full precision,
  larger models via QLoRA; cloud GPU (RunPod) for 70B+ fine-tuning
- Ollama API exposed to LAN at 0.0.0.0:11434 — other devices on 192.168.18.x can use it
