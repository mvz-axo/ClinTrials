# mvz-axo Research Platform — MCP Layer

The Model Context Protocol (MCP) layer exposes research tools to AI agents
running in Zed (or any MCP-compatible host). All MCP servers run as local
processes communicating over stdio or HTTP.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  ZED EDITOR — Agent Panel + Cline/Kilocode                         │
│  Primary LLM: Claude Sonnet 4.6 (via zed.dev)                      │
└──────────┬──────────────────────────────────────────────────────────┘
           │ MCP Protocol (stdio)
           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PLATFORM MCP SERVERS (shared across all research repos)            │
│                                                                     │
│  BIOMEDICAL KNOWLEDGE                                               │
│  ├─ BioMCP          — ClinicalTrials, PubMed, genes, variants,     │
│  │                    drugs, diseases, pathways (30+ tools)         │
│  ├─ PubMed MCP      — 36M+ citations, MeSH, PMC full text          │
│  ├─ UniProt MCP     — protein sequences, domains, structures        │
│  ├─ ChEMBL MCP      — drug discovery, bioactivity, ADMET           │
│  ├─ NCBI MCP        — genomes, genes, taxonomy, sequences           │
│  ├─ BioThings MCP   — MyGene (22M genes) + MyVariant (400M vars)   │
│  └─ BioOntology MCP — 1,200+ ontologies (MeSH, GO, SNOMED…)        │
│                                                                     │
│  DOCUMENT INTELLIGENCE (Arsenal / Kask substrate)                  │
│  ├─ arsenal-mcp-embedding  — PDF/MD → chunk → embed → Qdrant        │
│  ├─ arsenal-mcp-rss-reader — RSS/Atom/JSON feed subscriptions       │
│  └─ arsenal-mcp-logseq     — Logseq knowledge graph CRUD            │
│                                                                     │
│  INFRASTRUCTURE                                                     │
│  ├─ Qdrant MCP      — semantic vector search (already running)      │
│  ├─ Neo4j MCP       — knowledge graph Cypher queries                │
│  ├─ Memory MCP      — persistent cross-session knowledge graph      │
│  ├─ Filesystem MCP  — direct file read/write in research dirs       │
│  └─ GitHub MCP      — repos, issues, PRs (active via Zed ext.)     │
│                                                                     │
│  WEB + REASONING                                                    │
│  ├─ Brave Search MCP — privacy-respecting live web search           │
│  └─ Sequential Thinking MCP — structured multi-step reasoning       │
│                                                                     │
│  DOMAIN-SPECIFIC (each repo adds its own)                           │
│  └─ <domain>-mcp   — custom tools for this research domain          │
└──────────┬──────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LOCAL INFRASTRUCTURE                                               │
│  Ollama :11434  │  Qdrant :6333  │  Neo4j :7687  │  Unsloth :8888  │
└─────────────────────────────────────────────────────────────────────┘
```

## Complete Server Registry

All servers are configured in `.config/mcp/mcp_registry.json`.
To activate in Zed: copy the `zed_config` block into `~/.config/zed/settings.json`
under `"context_servers"`.

### Biomedical Knowledge Servers

| Server | Tools | Key required | Status | Install |
|--------|-------|-------------|--------|---------|
| **BioMCP** | 30+ | None | ✅ Active | `uv tool install biomcp-cli` |
| **PubMed MCP** | 12 | Optional: NCBI_API_KEY | 🔲 Install | npm (Augmented Nature) |
| **UniProt MCP** | 15 | None | 🔲 Install | npm (Augmented Nature) |
| **ChEMBL MCP** | 18 | None | 🔲 Install | npm (Augmented Nature) |
| **NCBI Datasets MCP** | 31 | Optional: NCBI_API_KEY | 🔲 Install | npm (Augmented Nature) |
| **BioThings MCP** | 10 | None | 🔲 Install | npm (Augmented Nature) |
| **BioOntology MCP** | 8 | **BIOPORTAL_API_KEY** 🔒 | 🔲 Install | npm (Augmented Nature) |

Install all Augmented Nature servers:
```bash
for server in pubmed uniprot chembl ncbi biothings bioontology; do
  git clone https://github.com/Augmented-Nature/${server}-mcp-server \
    ~/.mcp-servers/${server}
  cd ~/.mcp-servers/${server} && npm install && npm run build && cd -
done
```

### Document Intelligence Servers (Arsenal — pre-built)

| Server | Tools | Binary | Launch script |
|--------|-------|--------|---------------|
| **arsenal-mcp-embedding** | 7 | `~/.local/bin/arsenal-mcp-embedding` | `.config/mcp/run-embedding.sh` |
| **arsenal-mcp-rss-reader** | 19 | `~/.local/bin/arsenal-mcp-rss-reader` | `.config/mcp/run-rss-reader.sh` |
| **arsenal-mcp-logseq** | 8 | `~/.local/bin/arsenal-mcp-logseq` | `.config/mcp/run-logseq.sh` |

These are already built from the kask repository at `~/Clones/kask/`.
Rebuilt with: `cd ~/Clones/kask/arsenal && cargo build --release -p <name>`

**arsenal-mcp-embedding tools:**
- `embedding_vectorize_document` — PDF or Markdown → chunks → Ollama embed → Qdrant
- `embedding_vectorize_text` — embed a single passage
- `embedding_search` — semantic search across one or more collections
- `embedding_search_between` — bridge search between two concepts
- `embedding_list_collections` — list Qdrant collections
- `embedding_collection_info` — collection statistics
- `embedding_drop_collection` — delete a collection

**arsenal-mcp-rss-reader tools (19 total, Google Reader model):**
- Subscribe, unsubscribe, list subscriptions
- Fetch unread items, mark as read, star items
- Organize into folders, search across feeds
- Discover feeds from any URL

**arsenal-mcp-logseq tools:**
- `logseq_get_page`, `logseq_create_page`, `logseq_update_page`, `logseq_delete_page`
- `logseq_list_pages`, `logseq_search`, `logseq_get_backlinks`
- `logseq_get_block`, `logseq_get_page_properties`

### Infrastructure Servers

| Server | Tools | Key required | Status | Install |
|--------|-------|-------------|--------|---------|
| **Qdrant MCP** | 5 | None (local) | 🔲 Configure | `uvx mcp-server-qdrant` |
| **Neo4j MCP** | 10 | Neo4j running | 🔲 Install | Binary from GitHub |
| **Memory MCP** | 6 | None | 🔲 Configure | `npx @modelcontextprotocol/server-memory` |
| **Filesystem MCP** | 8 | None | 🔲 Configure | `npx @modelcontextprotocol/server-filesystem` |
| **GitHub MCP** | 25 | GITHUB_TOKEN | ✅ Active | Zed extension |
| **Sequential Thinking** | 1 | None | ✅ Active | Zed extension |

### Web + Search Servers

| Server | Tools | Key required | Status | Install |
|--------|-------|-------------|--------|---------|
| **Brave Search MCP** | 2 | **BRAVE_API_KEY** 🔒 | 🔲 Install | `npx @modelcontextprotocol/server-brave-search` |

Install Brave Search MCP and add to Zed:
```bash
# No install needed — npx handles it automatically
# Just add to ~/.config/zed/settings.json:
# {
#   "context_servers": {
#     "brave-search": {
#       "command": "npx",
#       "args": ["-y", "@modelcontextprotocol/server-brave-search"],
#       "env": { "BRAVE_API_KEY": "<your-key>" }
#     }
#   }
# }
```

## Activating Servers in Zed

Add entries to `~/.config/zed/settings.json` under `"context_servers"`.
Each entry in `mcp_registry.json` has a `zed_config` block — copy it directly.

```json
{
  "context_servers": {
    "biomcp": {
      "command": "biomcp",
      "args": ["serve"],
      "env": {}
    },
    "arsenal-embedding": {
      "command": "/home/mvz-axo/Clones/<repo>/.config/mcp/run-embedding.sh",
      "args": [],
      "env": {}
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "your-key-here" }
    }
  }
}
```

## Adding a New MCP Server

1. Add the server entry to `.config/mcp/mcp_registry.json` (with `zed_config`)
2. Create a wrapper script in `.config/mcp/run-<name>.sh` if env vars are needed
3. Add the entry to `architecture/05_technology/TOOL_REGISTRY.md`
4. Add the `zed_config` block to `~/.config/zed/settings.json`
5. Update this file (MCP_LAYER.md) with the new server's tools
