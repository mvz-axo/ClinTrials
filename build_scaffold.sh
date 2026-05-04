#!/usr/bin/env bash
# ================================================================
#  Research Repository Scaffold Builder
#  mvz-axo | michael@axolotl.partners
#
#  Repos: ClinTrials | mAb | FlourTag
#
#  Run from anywhere — script locates itself:
#    bash ClinTrials/build_scaffold.sh
#
#  No sudo required. No packages installed — just files created.
# ================================================================

set -euo pipefail

# CLONES_DIR = the directory containing ClinTrials, mAb and FlourTag
# Works whether the script lives at Clones/build_scaffold.sh
# or at Clones/ClinTrials/build_scaffold.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$SCRIPT_DIR/ClinTrials" && -d "$SCRIPT_DIR/mAb" ]]; then
  CLONES_DIR="$SCRIPT_DIR"
elif [[ -d "$(dirname "$SCRIPT_DIR")/ClinTrials" && -d "$(dirname "$SCRIPT_DIR")/mAb" ]]; then
  CLONES_DIR="$(dirname "$SCRIPT_DIR")"
else
  echo "❌  Cannot locate research repositories."
  echo "    Run this script from your Clones folder:"
  echo "    cd ~/Clones && bash build_scaffold.sh"
  exit 1
fi

# ── Colours ────────────────────────────────────────────────────
GRN='\033[0;32m'; BLU='\033[0;34m'; YLW='\033[1;33m'; CYN='\033[0;36m'; NC='\033[0m'

log_dir()  { echo -e "  ${BLU}📁${NC}  $1"; }
log_file() { echo -e "  ${GRN}📄${NC}  $1"; }
log_head() { echo -e "\n${YLW}━━━  $1  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
log_done() { echo -e "\n${CYN}  ✓  $1${NC}"; }

# ── Helpers ────────────────────────────────────────────────────
mkd() { mkdir -p "$1"; log_dir "$1"; }
# write_file <path> then pipe content via heredoc at call site
write_file() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  log_file "$path"
}

# ================================================================
#  COMMON SCAFFOLD
#  Called once per repo: build_common <REPO> <TITLE> <DESC>
# ================================================================
build_common() {
  local REPO="$1" TITLE="$2" DESC="$3"
  local R="$CLONES_DIR/$REPO"
  log_head "$REPO"

  # ── Directory tree ───────────────────────────────────────────
  for d in \
    .config/mcp/biomedical \
    .config/mcp/infrastructure \
    .config/llm/profiles \
    .config/databases \
    architecture/01_research \
    architecture/02_data \
    architecture/03_knowledge \
    architecture/04_agents \
    architecture/05_technology \
    data/raw \
    data/processed \
    data/external \
    data/embeddings \
    literature/papers \
    literature/books \
    literature/notes \
    literature/summaries \
    knowledge/graphs \
    knowledge/ontologies \
    knowledge/vectors \
    agents/personas \
    agents/prompts \
    agents/conversations \
    code/marimo \
    code/analysis \
    code/pipelines \
    code/utils \
    experiments/active \
    experiments/completed \
    experiments/archive \
    reports/findings \
    reports/visualizations \
    reports/publications
  do
    mkd "$R/$d"
  done

  # ── .gitignore ────────────────────────────────────────────────
  write_file "$R/.gitignore"
  cat > "$R/.gitignore" << 'GITIGNORE'
# ── Large data files (track structure, not content) ──────────
data/raw/
data/external/
data/embeddings/
*.csv
*.tsv
*.parquet
*.h5
*.hdf5
*.pkl
*.pickle
*.feather
*.bam
*.fastq
*.fastq.gz
*.vcf

# ── Python ───────────────────────────────────────────────────
__pycache__/
*.pyc
*.pyo
.venv/
venv/
env/
*.egg-info/
.pytest_cache/
dist/
build/

# ── Marimo notebooks are .py files — COMMIT them!
# Only ignore the runtime cache, never the notebook files
__marimo__/

# ── uv ──────────────────────────────────────────────────────
.python-version
# uv.lock should be committed for reproducibility

# ── Secrets & environment ────────────────────────────────────
.env
*.key
*.pem
*.p12

# ── Local databases ──────────────────────────────────────────
qdrant_storage/
neo4j_data/

# ── Node ────────────────────────────────────────────────────
node_modules/
*.log

# ── OS ──────────────────────────────────────────────────────
.DS_Store
Thumbs.db

# ── IDE ─────────────────────────────────────────────────────
.idea/
*.swp
*.swo
GITIGNORE

  # ── .env.example ─────────────────────────────────────────────
  write_file "$R/.env.example"
  cat > "$R/.env.example" << ENVEXAMPLE
# ================================================================
#  $TITLE — Environment Variables
#  cp .env.example .env  →  fill in values  →  never commit .env
#
#  LLM Policy: Anthropic (Claude) + open-weight models only.
#  Open-weight models run locally via Ollama (already installed).
# ================================================================

# ── Biomedical APIs ─────────────────────────────────────────
NCBI_API_KEY=            # https://www.ncbi.nlm.nih.gov/account  (free, optional — raises rate limits)
BIOPORTAL_API_KEY=       # https://bioportal.bioontology.org/accounts/new  (free, REQUIRED for BioOntology MCP)

# ── LLM — Anthropic (primary reasoning model) ───────────────
ANTHROPIC_API_KEY=       # https://console.anthropic.com

# ── LLM — Open-weight via Ollama (local, no API key needed) ─
OLLAMA_BASE_URL=http://localhost:11434   # Ollama is already installed
# Pull models with:  ollama pull <model_name>
# Medical:   ollama pull meditron:70b  |  ollama pull medllama2
# General:   ollama pull qwen2.5:14b  |  ollama pull glm4
# Embedding: ollama pull nomic-embed-text  |  ollama pull mxbai-embed-large

# ── LLM — HuggingFace (for gated models e.g. MedGemma) ─────
HUGGINGFACE_TOKEN=       # https://huggingface.co/settings/tokens
# MedGemma requires: accept license at https://huggingface.co/google/medgemma-4b-it

# ── Vector Database (Qdrant) ────────────────────────────────
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=
# Fully local mode (no Docker needed) — uses file storage:
QDRANT_LOCAL_PATH=\$HOME/.local/share/qdrant/$REPO

# ── Graph Database (Neo4j) ──────────────────────────────────
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=

# ── GitHub ──────────────────────────────────────────────────
GITHUB_TOKEN=            # https://github.com/settings/tokens
GITHUB_OWNER=mvz-axo
GITHUB_REPO=$REPO
ENVEXAMPLE

  # ── README.md ────────────────────────────────────────────────
  write_file "$R/README.md"
  cat > "$R/README.md" << README
# $TITLE

> $DESC

## Overview

Part of the **mvz-axo Research Platform** — a structured, AI-augmented research environment
combining knowledge graphs, embedding-based retrieval and collaborative AI researcher personas
to advance biomedical science.

## Repository Map

| Folder | Purpose |
|---|---|
| \`.config/\` | MCP servers, LLM profiles, database configurations |
| \`architecture/\` | TOGAF-lite research & system architecture docs |
| \`data/\` | Raw, processed, external & embedded data |
| \`literature/\` | Papers, books, notes & AI-generated summaries |
| \`knowledge/\` | Knowledge graphs, ontologies & vector collections |
| \`agents/\` | AI researcher personas, prompts & conversations |
| \`code/\` | Marimo notebooks (.py), analysis scripts & data pipelines |
| \`experiments/\` | Active, completed & archived experiments |
| \`reports/\` | Findings, visualizations & publications |

## Quick Start

\`\`\`bash
cp .env.example .env                          # Add your API keys
cat RESEARCH_PLAN.md                          # Review current goals
cat AGENT_ROSTER.md                           # Meet your AI collaborators

# Open a marimo notebook (installs sandbox deps automatically)
uvx marimo edit --sandbox code/marimo/explore.py

# Or run as a web app
uvx marimo run code/marimo/explore.py
\`\`\`

## Key Documents

| Document | Purpose |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System overview |
| [RESEARCH_PLAN.md](RESEARCH_PLAN.md) | Goals & methodology |
| [AGENT_ROSTER.md](AGENT_ROSTER.md) | AI research collaborators |
| [DATA_SOURCES.md](DATA_SOURCES.md) | Data source catalog |
| [HYPOTHESIS_LOG.md](HYPOTHESIS_LOG.md) | Hypothesis tracking |
| [DECISION_LOG.md](DECISION_LOG.md) | Decision records |
| [CHANGELOG.md](CHANGELOG.md) | Progress & milestones |
README

  # ── ARCHITECTURE.md ──────────────────────────────────────────
  write_file "$R/ARCHITECTURE.md"
  cat > "$R/ARCHITECTURE.md" << 'ARCH'
# Architecture Overview

## System Layers

```
┌────────────────────────────────────────────────────────────┐
│  RESEARCH LAYER                                            │
│  Questions  →  Hypotheses  →  Experiments  →  Findings    │
├────────────────────────────────────────────────────────────┤
│  AGENT LAYER                                               │
│  Researcher Personas  │  Prompts  │  Conversations        │
├────────────────────────────────────────────────────────────┤
│  KNOWLEDGE LAYER             │  LITERATURE LAYER          │
│  Neo4j Knowledge Graphs      │  Papers, Books, Notes      │
│  Domain Ontologies           │  Qdrant Semantic Search    │
├────────────────────────────────────────────────────────────┤
│  DATA LAYER                                                │
│  Raw  │  Processed  │  External APIs  │  Embeddings       │
├────────────────────────────────────────────────────────────┤
│  TOOL LAYER  (MCP)                                         │
│  BioMCP · PubMed · UniProt · ChEMBL · NCBI · BioThings   │
│  Qdrant · Neo4j · Memory · GitHub · Filesystem            │
├────────────────────────────────────────────────────────────┤
│  MODEL LAYER                                               │
│  Claude Sonnet 4.6  (reasoning + agents)                  │
│  all-MiniLM-L6-v2 / text-embedding-3-large  (embeddings) │
└────────────────────────────────────────────────────────────┘
```

## Architecture Docs

- [01 Research](architecture/01_research/VISION.md) — Vision, goals, methodology
- [02 Data](architecture/02_data/DATA_CATALOG.md) — Sources, flows, governance
- [03 Knowledge](architecture/03_knowledge/GRAPH_SCHEMA.md) — Graphs, ontologies, embeddings
- [04 Agents](architecture/04_agents/AGENT_FRAMEWORK.md) — Personas, prompts, patterns
- [05 Technology](architecture/05_technology/TOOL_REGISTRY.md) — MCP, databases, models
ARCH

  # ── RESEARCH_PLAN.md ─────────────────────────────────────────
  write_file "$R/RESEARCH_PLAN.md"
  cat > "$R/RESEARCH_PLAN.md" << RPLAN
# Research Plan — $TITLE

## Vision
> *[One paragraph: where does this research aim to go in 5 years?]*

## Core Research Questions
1.
2.
3.

## Current Focus
- [ ]
- [ ]
- [ ]

## Methodology
- **Approach:**
- **Primary data sources:** see [DATA_SOURCES.md](DATA_SOURCES.md)
- **Analysis methods:**
- **AI collaboration model:** see [architecture/04_agents/AGENT_FRAMEWORK.md](architecture/04_agents/AGENT_FRAMEWORK.md)

## Milestones

| Milestone | Target | Status |
|---|---|---|
| Scaffold & tooling setup | $(date +%Y-%m) | ✅ Done |
| BioMCP + PubMed connected | | 🔲 |
| First literature corpus embedded | | 🔲 |
| First knowledge graph populated | | 🔲 |
| First agent persona activated | | 🔲 |
| First research finding report | | 🔲 |
RPLAN

  # ── HYPOTHESIS_LOG.md ────────────────────────────────────────
  write_file "$R/HYPOTHESIS_LOG.md"
  cat > "$R/HYPOTHESIS_LOG.md" << 'HLOG'
# Hypothesis Log

Living record of research hypotheses, evidence and outcomes.

## Status key
🔵 Active · ✅ Supported · ❌ Refuted · ⏸ Paused · 🔄 Revised

---

## Template

```
### H-001: [Title]
- **Date:** YYYY-MM-DD
- **Statement:** Clear, testable, falsifiable hypothesis
- **Basis:** Prior knowledge or observation that motivates this
- **Predictions:** What we expect to observe if true
- **Test approach:** How to evaluate — data needed, method
- **Status:** 🔵 Active
- **Notes:**
```

---

## Active

*(Add your first hypothesis here)*

## Completed

*(Move here when resolved)*
HLOG

  # ── DECISION_LOG.md ──────────────────────────────────────────
  write_file "$R/DECISION_LOG.md"
  cat > "$R/DECISION_LOG.md" << DLOG
# Decision Log

Architectural and methodological decisions, with rationale.
Format inspired by Architecture Decision Records (ADR).

---

## DR-001: Repository scaffold design
- **Date:** $(date +%Y-%m-%d)
- **Decision:** TOGAF-lite scaffold — artifact type at top level, domain concepts at second level
- **Rationale:** Consistent cross-repo structure; flexible domain expansion; supports knowledge graph + RAG + agent workflows from day one
- **Alternatives considered:** Flat structure; domain-first structure
- **Status:** ✅ Accepted

---

## Template

\`\`\`
## DR-XXX: [Title]
- **Date:** YYYY-MM-DD
- **Decision:** What was decided
- **Rationale:** Why this option
- **Alternatives considered:**
- **Status:** ✅ Accepted | 🔄 Revised | ❌ Superseded
\`\`\`
DLOG

  # ── AGENT_ROSTER.md ──────────────────────────────────────────
  write_file "$R/AGENT_ROSTER.md"
  cat > "$R/AGENT_ROSTER.md" << 'ROSTER'
# Agent Roster

Your AI research collaborators. Each persona brings a distinct expert perspective.
Full persona definitions live in `agents/personas/`.

## Active Personas

| Handle | Expertise | Modelled On | Prompt File |
|---|---|---|---|
| *(Build your roster in agents/personas/)* | | | |

## Collaboration Patterns

See `architecture/04_agents/COLLABORATION_PATTERNS.md` for how to run:
- **The Symposium** — Multi-persona hypothesis evaluation
- **The Relay** — Sequential deep literature review
- **The Build** — Collaborative experimental design
- **The Code Review** — Methodological analysis review

## Design a New Persona

See `architecture/04_agents/PERSONA_DESIGN.md` for the full template.
ROSTER

  # ── DATA_SOURCES.md ──────────────────────────────────────────
  write_file "$R/DATA_SOURCES.md"
  cat > "$R/DATA_SOURCES.md" << DSOURCES
# Data Sources — $TITLE

## Public Databases (via MCP)

| Source | What it provides | MCP Server | API Key |
|---|---|---|---|
| PubMed / PMC | 36M+ biomedical citations, full text | biomcp, pubmed | Optional (NCBI) |
| ClinicalTrials.gov | Trial registry, protocols, results | biomcp | None |
| UniProt | Protein sequences, functions, pathways | uniprot | None |
| ChEMBL | Drug bioactivity, ADMET, mechanisms | chembl | None |
| NCBI Datasets | Genomes, genes, sequences, taxonomy | ncbi | Optional (NCBI) |
| BioThings (MyGene/MyVariant) | Gene/variant annotation at scale | biothings | None |
| BioOntology | 1,200+ biological ontologies | bioontology | ✅ BioPortal |

## Domain-Specific Sources

| Source | URL | Notes |
|---|---|---|
| *(Add as research expands)* | | |

## Local Datasets

| Dataset | Location | Format | Updated |
|---|---|---|---|
| | | | |

## API Keys Needed

| Service | Register at | Cost |
|---|---|---|
| NCBI (higher rate limits) | https://www.ncbi.nlm.nih.gov/account | Free |
| BioPortal (BioOntology) | https://bioportal.bioontology.org/accounts/new | Free |

## Licensing

| Source | License |
|---|---|
| PubMed abstracts | Public domain |
| PMC full text | Various (CC BY common for OA) |
| UniProt | CC BY 4.0 |
| ChEMBL | CC BY-SA 3.0 |
| ClinicalTrials.gov | Public domain |
DSOURCES

  # ── CHANGELOG.md ─────────────────────────────────────────────
  write_file "$R/CHANGELOG.md"
  cat > "$R/CHANGELOG.md" << CHLOG
# Changelog — $TITLE

## [$(date +%Y-%m-%d)] — Initial scaffold

### Added
- TOGAF-lite research architecture documentation framework
- MCP server registry: 7 biomedical + 5 infrastructure servers configured
- LLM profiles: deep_reasoning · literature_review · data_analysis · hypothesis_gen · scientific_writing
- Database configs: Qdrant (vector) + Neo4j (graph)
- Agent persona framework with domain-specific starter rosters
- Research plan, hypothesis log, decision log templates
- Domain-specific knowledge graph schemas and data source directories

---

## Format
\`\`\`
## [YYYY-MM-DD] — Sprint name
### Added | Changed | Fixed | Removed
- Description
\`\`\`
CHLOG

  # ================================================================
  #  .config — MCP REGISTRY
  # ================================================================

  write_file "$R/.config/mcp/mcp_registry.json"
  cat > "$R/.config/mcp/mcp_registry.json" << 'MCPREG'
{
  "_readme": "Master MCP server registry. Set enabled:true and install each server before activating. Install instructions in each server's config file.",
  "_zed_note": "To activate in Zed: add to ~/.config/zed/settings.json under context_servers. See architecture/05_technology/MCP_ARCHITECTURE.md",

  "biomedical": {

    "biomcp": {
      "enabled": true,
      "description": "Unified biomedical access — ClinicalTrials, PubMed, genes, variants, drugs, diseases, pathways",
      "install": "pip install biomcp-cli",
      "verify": "biomcp --version && biomcp health --apis-only",
      "docs": "https://biomcp.org",
      "api_keys_required": false,
      "zed_config": {
        "command": "biomcp",
        "args": ["serve"],
        "env": {}
      }
    },

    "pubmed": {
      "enabled": false,
      "description": "PubMed — 36M+ citations, MeSH search, full text via PMC, citations/references",
      "install": "git clone https://github.com/Augmented-Nature/PubMed-MCP-Server ~/.mcp-servers/pubmed && cd ~/.mcp-servers/pubmed && npm install && npm run build",
      "api_keys_required": false,
      "api_keys_optional": ["NCBI_API_KEY"],
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/pubmed/build/index.js"],
        "env": { "NCBI_API_KEY": "${NCBI_API_KEY}" }
      }
    },

    "uniprot": {
      "enabled": false,
      "description": "UniProt — protein sequences, domains, variants, pathways, interactions, 3D structures (PDB)",
      "install": "git clone https://github.com/augmented-nature/uniprot-mcp-server ~/.mcp-servers/uniprot && cd ~/.mcp-servers/uniprot && npm install && npm run build",
      "api_keys_required": false,
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/uniprot/build/index.js"],
        "env": {}
      }
    },

    "chembl": {
      "enabled": false,
      "description": "ChEMBL — drug discovery, bioactivity assays, ADMET properties, mechanisms of action, similarity search",
      "install": "git clone https://github.com/augmented-nature/chembl-mcp-server ~/.mcp-servers/chembl && cd ~/.mcp-servers/chembl && npm install && npm run build",
      "api_keys_required": false,
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/chembl/build/index.js"],
        "env": {}
      }
    },

    "ncbi": {
      "enabled": false,
      "description": "NCBI Datasets — genomes, genes, taxonomy, sequences (31 tools)",
      "install": "git clone https://github.com/Augmented-Nature/NCBI-Datasets-MCP-Server ~/.mcp-servers/ncbi && cd ~/.mcp-servers/ncbi && npm install && npm run build",
      "api_keys_optional": ["NCBI_API_KEY"],
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/ncbi/build/index.js"],
        "env": { "NCBI_API_KEY": "${NCBI_API_KEY}" }
      }
    },

    "biothings": {
      "enabled": false,
      "description": "BioThings.io — MyGene (22M+ genes across 22K species) + MyVariant (400M+ human variants)",
      "install": "git clone https://github.com/Augmented-Nature/BioThings-MCP-Server ~/.mcp-servers/biothings && cd ~/.mcp-servers/biothings && npm install && npm run build",
      "api_keys_required": false,
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/biothings/build/index.js"],
        "env": {}
      }
    },

    "bioontology": {
      "enabled": false,
      "description": "BioOntology / BioPortal — 1,200+ biological ontologies, term search, text annotation, ontology recommendations",
      "install": "git clone https://github.com/augmented-nature/bioontology-mcp-server ~/.mcp-servers/bioontology && cd ~/.mcp-servers/bioontology && npm install && npm run build",
      "api_keys_required": true,
      "api_key_name": "BIOONTOLOGY_API_KEY",
      "api_key_url": "https://bioportal.bioontology.org/accounts/new",
      "zed_config": {
        "command": "node",
        "args": ["~/.mcp-servers/bioontology/build/index.js"],
        "env": { "BIOONTOLOGY_API_KEY": "${BIOPORTAL_API_KEY}" }
      }
    }

  },

  "infrastructure": {

    "qdrant": {
      "enabled": false,
      "description": "Qdrant vector database — semantic memory, embedding search, RAG retrieval",
      "install": "pip install uv  (uvx handles the rest automatically)",
      "local_mode_note": "No Docker needed — set QDRANT_LOCAL_PATH for fully local file-based mode",
      "zed_config": {
        "command": "uvx",
        "args": ["mcp-server-qdrant"],
        "env": {
          "QDRANT_LOCAL_PATH": "~/.local/share/qdrant",
          "COLLECTION_NAME": "research",
          "EMBEDDING_MODEL": "sentence-transformers/all-MiniLM-L6-v2",
          "EMBEDDING_PROVIDER": "fastembed"
        }
      }
    },

    "neo4j": {
      "enabled": false,
      "description": "Neo4j graph database — knowledge graph storage, Cypher queries, schema exploration",
      "install": "Download binary from https://github.com/neo4j/mcp/releases and place in PATH",
      "database_install": "Docker: docker run -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/yourpassword -e NEO4J_PLUGINS='[\"apoc\"]' neo4j",
      "zed_config": {
        "command": "neo4j-mcp",
        "args": [],
        "env": {
          "NEO4J_URI": "${NEO4J_URI}",
          "NEO4J_USERNAME": "${NEO4J_USERNAME}",
          "NEO4J_PASSWORD": "${NEO4J_PASSWORD}"
        }
      }
    },

    "memory": {
      "enabled": false,
      "description": "Persistent knowledge graph memory — entities, relations and observations that survive across agent sessions",
      "install": "npx handles automatically (requires Node.js)",
      "zed_config": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-memory"],
        "env": {}
      }
    },

    "filesystem": {
      "enabled": false,
      "description": "Local filesystem access — lets agents read and write research files directly",
      "install": "npx handles automatically",
      "zed_config": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/mvz-axo/Clones"],
        "env": {}
      }
    },

    "github": {
      "enabled": true,
      "description": "GitHub integration — repos, issues, PRs, code search",
      "install": "Already active via Zed mcp-server-github extension",
      "zed_config": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
      }
    },

    "sequential_thinking": {
      "enabled": true,
      "description": "Structured multi-step reasoning for complex research problems",
      "install": "Already active via Zed mcp-server-sequential-thinking extension"
    }

  }
}
MCPREG

  # ── LLM Model Registry ───────────────────────────────────────
  write_file "$R/.config/llm/model_registry.json"
  cat > "$R/.config/llm/model_registry.json" << 'MODELS'
{
  "_policy": "Anthropic Claude (primary reasoning via Zed) + open-weight models via Ollama. No closed proprietary models outside Anthropic.",
  "_ollama_installed": true,
  "_ollama_url": "http://localhost:11434",

  "primary_reasoning": {

    "claude-sonnet-4-6": {
      "provider": "zed.dev (Anthropic)",
      "context_window": 200000,
      "supports_extended_thinking": true,
      "weights": "closed — Anthropic exception allowed",
      "best_for": ["deep hypothesis generation", "literature synthesis", "complex multi-step analysis", "experimental design", "scientific writing"],
      "use_profile": "deep_reasoning.json",
      "zed_setting": { "provider": "zed.dev", "model": "claude-sonnet-4-6", "effort": "high", "enable_thinking": true }
    },

    "claude-haiku": {
      "provider": "zed.dev (Anthropic)",
      "weights": "closed — Anthropic exception allowed",
      "best_for": ["quick lookups", "simple formatting", "rapid iteration"],
      "zed_setting": { "provider": "zed.dev", "model": "claude-haiku", "effort": "low", "enable_thinking": false }
    }

  },

  "open_general": {
    "_note": "All run locally via Ollama. No API key required. Pull with: ollama pull <model>",

    "qwen2.5:14b": {
      "developer": "Alibaba Cloud",
      "license": "Apache 2.0",
      "params": "14B",
      "context": "128K",
      "ollama_pull": "ollama pull qwen2.5:14b",
      "size_on_disk": "~9GB",
      "best_for": ["literature analysis", "structured data", "multilingual research", "JSON output", "biomedical QA"],
      "notes": "Strong science and medical reasoning. Good balance of capability vs size for local use."
    },

    "qwen2.5:32b": {
      "developer": "Alibaba Cloud",
      "license": "Apache 2.0",
      "params": "32B",
      "context": "128K",
      "ollama_pull": "ollama pull qwen2.5:32b",
      "size_on_disk": "~20GB",
      "best_for": ["complex reasoning", "long document analysis", "agent tasks"],
      "notes": "Best Qwen size for serious research tasks if you have the RAM."
    },

    "qwen2.5:72b": {
      "developer": "Alibaba Cloud",
      "license": "Qwen License (open, non-commercial restriction on 72B)",
      "params": "72B",
      "context": "128K",
      "ollama_pull": "ollama pull qwen2.5:72b",
      "size_on_disk": "~47GB",
      "best_for": ["highest quality local reasoning", "frontier-level biomedical analysis"],
      "notes": "Requires substantial RAM. Check Qwen License for 72B non-commercial use."
    },

    "glm4:9b": {
      "developer": "Zhipu AI (Tsinghua University)",
      "license": "Apache 2.0",
      "params": "9B",
      "context": "128K",
      "ollama_pull": "ollama pull glm4",
      "size_on_disk": "~6GB",
      "best_for": ["multilingual biomedical text", "Chinese-language literature", "mixed-language research"],
      "notes": "Architecturally bilingual (Chinese+English). Excellent for international research literature."
    },

    "kimi-k2.5": {
      "developer": "Moonshot AI",
      "license": "Open weights",
      "ollama_pull": "ollama pull kimi-k2.5",
      "best_for": ["long context reasoning", "document analysis"],
      "notes": "Available in Ollama library. Strong long-context performance."
    },

    "phi4:14b": {
      "developer": "Microsoft",
      "license": "MIT",
      "params": "14B",
      "ollama_pull": "ollama pull phi4",
      "size_on_disk": "~9GB",
      "best_for": ["reasoning", "STEM tasks", "fast local inference"],
      "notes": "Strong on reasoning benchmarks. MIT license — very permissive."
    },

    "deepseek-v3": {
      "developer": "DeepSeek AI",
      "license": "MIT",
      "ollama_pull": "ollama pull deepseek-v3",
      "best_for": ["complex reasoning", "code", "scientific analysis"],
      "notes": "MoE architecture — very capable. MIT licensed."
    }

  },

  "open_medical": {
    "_note": "Biomedical and clinical domain fine-tuned open-weight models",

    "meditron:70b": {
      "developer": "EPFL",
      "license": "Llama 2 Community License",
      "params": "70B",
      "base_model": "Llama 2",
      "ollama_pull": "ollama pull meditron:70b",
      "size_on_disk": "~39GB",
      "training_data": "PubMed Central, medical guidelines",
      "benchmarks": "Outperforms GPT-3.5 on MedQA, within 5% of GPT-4",
      "best_for": ["medical QA", "clinical guidelines", "differential diagnosis", "evidence-based reasoning"],
      "notes": "Gold standard open medical LLM. Requires substantial RAM for 70B."
    },

    "meditron:7b": {
      "developer": "EPFL",
      "license": "Llama 2 Community License",
      "params": "7B",
      "ollama_pull": "ollama pull meditron:7b",
      "size_on_disk": "~3.8GB",
      "best_for": ["fast medical QA", "low-resource environments", "batch processing"],
      "notes": "Smaller, faster. Good for rapid literature screening."
    },

    "llama3-meditron:70b": {
      "developer": "EPFL (updated)",
      "license": "Llama 3 Community License",
      "params": "70B",
      "base_model": "Llama 3.1",
      "huggingface": "epfl-llm/meditron-llama3-70b",
      "ollama_pull": "Import from HuggingFace (see HF import docs)",
      "training_data": "PubMed Central, textbooks, clinical practice guidelines",
      "benchmarks": "Outperforms all Llama 3.1 models on MedMCQA/MedQA/PubMedQA",
      "best_for": ["state-of-the-art open medical reasoning", "physician-level QA"],
      "notes": "Best open medical model available. Co-designed with physicians. Import via HF."
    },

    "medgemma:4b": {
      "developer": "Google",
      "license": "Health AI Developer Foundations License (open weights, research use)",
      "params": "4B",
      "base_model": "Gemma 3",
      "huggingface": "google/medgemma-4b-it",
      "multimodal": true,
      "modalities": ["text", "medical images", "radiology", "histopathology", "ophthalmology"],
      "ollama_pull": "ollama pull medgemma  (or import from HuggingFace)",
      "hf_access": "Gated — accept license at huggingface.co/google/medgemma-4b-it",
      "best_for": ["medical image analysis", "radiology report generation", "histopathology", "multimodal biomedical tasks"],
      "notes": "Unique multimodal capability — can analyse medical images. HUGGINGFACE_TOKEN required."
    },

    "medgemma:27b": {
      "developer": "Google",
      "license": "Health AI Developer Foundations License",
      "params": "27B",
      "modalities": ["text"],
      "huggingface": "google/medgemma-27b-text-it",
      "hf_access": "Gated — accept license at HuggingFace",
      "best_for": ["deep medical text reasoning", "clinical document understanding", "EHR interpretation"],
      "notes": "Text-only. Best performance for medical text tasks among the MedGemma family."
    },

    "biomistral:7b": {
      "developer": "LIA / Nantes University (ACL 2024)",
      "license": "Apache 2.0",
      "params": "7B",
      "base_model": "Mistral 7B",
      "huggingface": "BioMistral/BioMistral-7B",
      "training_data": "PubMed Central full text",
      "ollama_pull": "Import from HuggingFace",
      "best_for": ["biomedical literature QA", "multilingual medical text", "PubMed-grounded reasoning"],
      "notes": "Pre-trained on PubMed Central. Evaluated on 10 medical QA benchmarks."
    },

    "mediphi-clinical": {
      "developer": "Microsoft",
      "license": "MIT",
      "base_model": "Phi-3.5-mini-instruct",
      "huggingface": "microsoft/MediPhi-Clinical",
      "training_data": "Clinical notes, PMC-Patients, NoteChat",
      "best_for": ["clinical note understanding", "EHR extraction", "lightweight clinical reasoning"],
      "notes": "MIT licensed. Very small footprint. Good for structured data extraction from clinical text."
    }

  },

  "embedding_models": {
    "_note": "All open-weight. Run locally via Ollama or sentence-transformers. No API key required.",

    "nomic-embed-text": {
      "provider": "Ollama (Nomic AI)",
      "license": "Apache 2.0",
      "dimensions": 768,
      "ollama_pull": "ollama pull nomic-embed-text",
      "context": "8192 tokens",
      "best_for": ["general literature search", "production RAG", "long documents"],
      "notes": "Excellent quality, long context window, fast. Recommended default."
    },

    "mxbai-embed-large": {
      "provider": "Ollama (mixedbread.ai)",
      "license": "Apache 2.0",
      "dimensions": 1024,
      "ollama_pull": "ollama pull mxbai-embed-large",
      "best_for": ["highest quality semantic search", "scientific literature"],
      "notes": "State-of-the-art on MTEB benchmark. Best quality among free local models."
    },

    "bge-m3": {
      "provider": "Ollama (BAAI)",
      "license": "MIT",
      "dimensions": 1024,
      "ollama_pull": "ollama pull bge-m3",
      "best_for": ["multilingual biomedical search", "cross-lingual literature"],
      "notes": "Multi-lingual, multi-granularity. Excellent for international literature."
    },

    "qwen3-embedding": {
      "provider": "Ollama (Alibaba)",
      "license": "Apache 2.0",
      "ollama_pull": "ollama pull qwen3-embedding",
      "best_for": ["multilingual scientific text", "long biomedical documents"],
      "notes": "New Qwen3 embedding — strong multilingual scientific performance."
    },

    "all-MiniLM-L6-v2": {
      "provider": "sentence-transformers / Qdrant fastembed (local)",
      "license": "Apache 2.0",
      "dimensions": 384,
      "install": "Built into mcp-server-qdrant via fastembed — no separate install needed",
      "best_for": ["development", "fast iteration", "Qdrant default"],
      "notes": "Fastest to get started. Lower quality than nomic/mxbai but zero friction."
    }

  }
}
MODELS

  # ── LLM Profiles ─────────────────────────────────────────────
  write_file "$R/.config/llm/profiles/deep_reasoning.json"
  cat > "$R/.config/llm/profiles/deep_reasoning.json" << 'PROF'
{
  "profile": "deep_reasoning",
  "description": "Complex multi-step analysis, synthesising contradictory evidence, novel hypothesis generation",
  "use_when": [
    "Generating novel hypotheses from literature",
    "Synthesising large bodies of contradictory evidence",
    "Designing rigorous experimental approaches",
    "Evaluating alternative mechanistic explanations"
  ],
  "model": "claude-sonnet-4-6",
  "settings": { "effort": "high", "enable_thinking": true },
  "mcp_recommended": ["biomcp", "pubmed", "memory", "neo4j", "sequential_thinking"],
  "system_prompt_prefix": "You are a rigorous scientific reasoning system. Think step by step. Consider alternative explanations before concluding. Clearly distinguish between: established fact (cite source), reasonable inference (note basis), and speculation (flag explicitly). When reviewing evidence, assess study quality (RCT > cohort > case-control > in vitro). Identify contradictions and propose what additional evidence would resolve them."
}
PROF

  write_file "$R/.config/llm/profiles/literature_review.json"
  cat > "$R/.config/llm/profiles/literature_review.json" << 'PROF'
{
  "profile": "literature_review",
  "description": "Systematic search, summary and synthesis of research literature",
  "use_when": [
    "Mapping a new research topic",
    "Comparing findings across multiple studies",
    "Identifying research gaps and open questions",
    "Building annotated bibliographies"
  ],
  "model": "claude-sonnet-4-6",
  "settings": { "effort": "medium", "enable_thinking": false },
  "mcp_recommended": ["biomcp", "pubmed", "memory"],
  "output_structure": "Background | Key Findings | Contradictions | Gaps | Recommended Reading",
  "system_prompt_prefix": "You are a systematic literature reviewer. Prioritise recent, high-quality evidence (prefer RCTs and meta-analyses). Flag contradictory findings and note limitations of each study. Summarise in the structure: Background → Key Findings → Contradictions & Debates → Open Questions → Top 5 Papers to Read. Always note the date range of evidence covered."
}
PROF

  write_file "$R/.config/llm/profiles/data_analysis.json"
  cat > "$R/.config/llm/profiles/data_analysis.json" << 'PROF'
{
  "profile": "data_analysis",
  "description": "Statistical analysis, pipeline design and results interpretation",
  "use_when": [
    "Analysing clinical or experimental datasets",
    "Writing reproducible analysis pipelines",
    "Interpreting statistical results",
    "Creating publication-quality visualisations"
  ],
  "model": "claude-sonnet-4-6",
  "settings": { "effort": "high", "enable_thinking": true },
  "mcp_recommended": ["qdrant", "filesystem"],
  "system_prompt_prefix": "You are a precise biomedical data scientist. Write clean, well-documented Python. Always: (1) check statistical assumptions before applying tests, (2) report effect sizes alongside p-values, (3) flag potential confounders, (4) make analyses reproducible with set seeds and version pins. Prefer pandas, scipy, statsmodels, matplotlib/plotly. Structure outputs: Method → Assumptions Check → Results → Interpretation → Limitations."
}
PROF

  write_file "$R/.config/llm/profiles/hypothesis_gen.json"
  cat > "$R/.config/llm/profiles/hypothesis_gen.json" << 'PROF'
{
  "profile": "hypothesis_gen",
  "description": "Creative, cross-domain ideation of novel, testable research hypotheses",
  "use_when": [
    "Brainstorming new research directions",
    "Finding unexpected connections across disciplines",
    "Challenging existing assumptions in the field",
    "Expanding the boundaries of current thinking"
  ],
  "model": "claude-sonnet-4-6",
  "settings": { "effort": "high", "enable_thinking": true },
  "mcp_recommended": ["biomcp", "pubmed", "memory", "neo4j", "sequential_thinking"],
  "system_prompt_prefix": "You are a bold scientific thinker. Draw unexpected connections across biology, chemistry, physics and medicine. For each hypothesis generated, provide: (1) Statement — clear and falsifiable, (2) Novelty score 1-10 with reasoning, (3) Feasibility score 1-10 with reasoning, (4) Potential impact score 1-10 with reasoning, (5) Minimal viable experiment to test it, (6) 2-3 existing papers that partially support or contradict it. Prioritise ideas that challenge consensus assumptions."
}
PROF

  write_file "$R/.config/llm/profiles/scientific_writing.json"
  cat > "$R/.config/llm/profiles/scientific_writing.json" << 'PROF'
{
  "profile": "scientific_writing",
  "description": "Drafting manuscripts, reports, grant sections and presentations",
  "use_when": [
    "Writing or refining manuscript sections",
    "Drafting research reports and findings",
    "Preparing grant application text",
    "Creating presentation narratives"
  ],
  "model": "claude-sonnet-4-6",
  "settings": { "effort": "medium", "enable_thinking": false },
  "system_prompt_prefix": "You are a precise scientific writer. Use clear, active voice. Avoid unnecessary jargon — if jargon is needed, define it on first use. Follow IMRaD structure where appropriate (Introduction, Methods, Results, Discussion). Mark where citations are needed with [CITE: topic]. Match the formality and style of the target venue. Flag any claims that require stronger evidence before publication."
}
PROF

  # ── Database configs ─────────────────────────────────────────
  write_file "$R/.config/databases/qdrant.yaml"
  cat > "$R/.config/databases/qdrant.yaml" << QDRANT
# Qdrant Vector Database — $TITLE
# Docs: https://qdrant.tech/documentation/
#
# Option A: Fully local (no Docker) — set mode: local
# Option B: Docker — docker run -p 6333:6333 qdrant/qdrant

mode: local
local_path: ~/.local/share/qdrant/$REPO
url: http://localhost:6333      # Used when mode: remote

collections:
  literature:
    description: Embedded research papers, book chapters and review articles
    vector_size: 384            # all-MiniLM-L6-v2  |  use 3072 for text-embedding-3-large
    distance: Cosine
    chunking: section-aware
    chunk_size: 512
    chunk_overlap: 50

  knowledge_nodes:
    description: Embedded summaries of knowledge graph nodes for semantic retrieval
    vector_size: 384
    distance: Cosine

  agent_conversations:
    description: Embedded agent conversation logs for cross-session recall
    vector_size: 384
    distance: Cosine

  experiment_logs:
    description: Embedded experimental protocols and results
    vector_size: 384
    distance: Cosine
QDRANT

  write_file "$R/.config/databases/neo4j.yaml"
  cat > "$R/.config/databases/neo4j.yaml" << NEO
# Neo4j Graph Database — $TITLE
# Docs: https://neo4j.com/docs/
#
# Install options:
#   Desktop app: https://neo4j.com/download/
#   Docker:      docker run -p 7474:7474 -p 7687:7687 \\
#                  -e NEO4J_AUTH=neo4j/yourpassword \\
#                  -e NEO4J_PLUGINS='["apoc"]' neo4j

connection:
  uri: bolt://localhost:7687
  username: neo4j
  password:                     # Set in .env as NEO4J_PASSWORD
  database: neo4j

# ── Core node types (domain-specific additions in GRAPH_SCHEMA.md) ──
node_labels:
  - Paper
  - Gene
  - Protein
  - Drug
  - Disease
  - Pathway
  - Trial
  - Researcher
  - Institution
  - Concept
  - Ontology_Term

# ── Core relationship types ─────────────────────────────────────────
relationship_types:
  - CITES            # Paper → Paper
  - TARGETS          # Drug → Protein
  - TREATS           # Drug → Disease
  - CAUSES           # Gene/Variant → Disease
  - PART_OF          # Gene → Pathway
  - ASSOCIATED_WITH  # Gene ↔ Disease (GWAS, etc.)
  - PUBLISHED_BY     # Paper → Researcher/Institution
  - CONDUCTED_BY     # Trial → Institution
  - RELATED_TO       # Concept ↔ Concept
  - ANNOTATED_AS     # Paper/Gene/Drug → Ontology_Term
NEO

  # ================================================================
  #  ARCHITECTURE DOCS
  # ================================================================

  write_file "$R/architecture/01_research/VISION.md"
  cat > "$R/architecture/01_research/VISION.md" << VISION
# Research Vision — $TITLE

## Long-Term Vision (5–10 years)

> *[Where could this research lead? What problem does it solve for patients, scientists or medicine?]*

## Medium-Term Goals (1–3 years)

> *[What do you aim to establish, publish or build in the next 1–3 years?]*

## Immediate Goals (next 6 months)

> *[What is the first tangible output you are working toward?]*

## Guiding Principles

1. **Reproducibility** — all analyses reproducible from raw data; code versioned in git
2. **Open science** — prefer open data sources and open methodologies
3. **AI augmentation** — AI amplifies scientific judgement; the researcher decides
4. **Continuous capture** — hypotheses, decisions and findings logged as they emerge
5. **Cross-domain thinking** — actively seek connections outside the immediate domain
VISION

  write_file "$R/architecture/01_research/METHODOLOGY.md"
  cat > "$R/architecture/01_research/METHODOLOGY.md" << 'METHOD'
# Research Methodology

## AI Collaboration Framework

| Step | AI Role | Researcher Role |
|---|---|---|
| Literature synthesis | Searches, summarises, connects | Evaluates, curates, judges relevance |
| Hypothesis generation | Proposes candidates, scores novelty/feasibility | Applies domain knowledge, selects |
| Data analysis | Writes and runs code, checks assumptions | Interprets results, flags confounders |
| Experimental design | Drafts protocol, identifies controls | Refines, approves, takes responsibility |
| Scientific writing | Drafts, structures, flags citation gaps | Edits, verifies accuracy, submits |

## Quality Controls

- All AI-generated hypotheses grounded in cited literature before advancement to HYPOTHESIS_LOG
- Statistical analyses reviewed for assumption violations before interpretation
- Agent conversations archived in `agents/conversations/` for audit trail
- Code reviewed and tested before use in published analyses

## Data Standards

- Raw data never modified — all transformations go to `data/processed/`
- Datasets registered in `DATA_SOURCES.md` before use in analysis
- All pipelines versioned in `code/pipelines/` with docstrings
- Experiment protocols logged in `experiments/` before execution
METHOD

  write_file "$R/architecture/03_knowledge/GRAPH_SCHEMA.md"
  cat > "$R/architecture/03_knowledge/GRAPH_SCHEMA.md" << 'GSCHEMA'
# Knowledge Graph Schema

## Core Node Types

| Node | Key Properties | Source |
|---|---|---|
| Paper | pmid, doi, title, year, journal, abstract | PubMed |
| Gene | symbol, entrez_id, ensembl_id, name, organism | NCBI, UniProt |
| Protein | uniprot_id, name, sequence, organism | UniProt |
| Drug | chembl_id, name, smiles, moa, phase | ChEMBL |
| Disease | mesh_id, doid, icd10, name | MeSH, DOID |
| Pathway | reactome_id, kegg_id, name, species | Reactome, KEGG |
| Trial | nct_id, phase, status, sponsor, n_enrolled | ClinicalTrials.gov |
| Ontology_Term | term_id, name, ontology, definition | BioOntology |

## Core Relationship Types

| Relationship | From | To | Key Properties |
|---|---|---|---|
| CITES | Paper | Paper | — |
| TARGETS | Drug | Protein | binding_affinity, assay_type, ic50 |
| TREATS | Drug | Disease | evidence_level, trial_phase |
| CAUSES | Gene | Disease | evidence_type, p_value |
| PART_OF | Gene/Protein | Pathway | role |
| ASSOCIATED_WITH | Gene | Disease | gwas_p_value, study_type |
| ANNOTATED_AS | Paper/Gene/Drug | Ontology_Term | confidence |

## Domain-Specific Extensions

> Add domain-specific node and relationship types below as research expands.
> See domain README files in `knowledge/graphs/` subdirectories.
GSCHEMA

  write_file "$R/architecture/03_knowledge/EMBEDDING_STRATEGY.md"
  cat > "$R/architecture/03_knowledge/EMBEDDING_STRATEGY.md" << 'EMBSTRAT'
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
EMBSTRAT

  write_file "$R/architecture/04_agents/AGENT_FRAMEWORK.md"
  cat > "$R/architecture/04_agents/AGENT_FRAMEWORK.md" << 'AGFW'
# Agent Framework

## Philosophy

Each AI research persona is modelled on the *mindset, methodology and critical perspective*
of a leading researcher — not a simulation of that person. The goal is to bring genuinely
diverse expert viewpoints to bear on your research questions, exposing blind spots and
generating ideas you would not reach alone.

## Persona File Structure

Each persona lives in `agents/personas/{domain}/{handle}.md` and contains:

1. **Identity** — handle, expertise, who they are modelled on
2. **Perspective** — their characteristic way of approaching problems
3. **Strengths** — what they are best at contributing
4. **Blind spots** — where their view is limited (who to cross-check with)
5. **Favourite questions** — their characteristic challenges
6. **Full system prompt** — ready to paste into Cline / Kilocode / Zed agent

## Activating a Persona

In Zed / Cline / Kilocode: paste the persona's system prompt as the agent's
system instructions, then begin the research conversation.

## Recommended Archetype Mix

| Archetype | Brings | Balance with |
|---|---|---|
| The Mechanist | Causal mechanisms, molecular detail | The Epidemiologist |
| The Epidemiologist | Population data, confounders, statistics | The Mechanist |
| The Devil's Advocate | Challenges assumptions, finds flaws | The Synthesiser |
| The Synthesiser | Cross-domain connections, big picture | The Devil's Advocate |
| The Clinician | Patient relevance, translation gap | The Basic Scientist |
| The Engineer | Feasibility, constraints, scale-up | The Visionary |
AGFW

  write_file "$R/architecture/04_agents/PERSONA_DESIGN.md"
  cat > "$R/architecture/04_agents/PERSONA_DESIGN.md" << 'PDES'
# Persona Design Template

Copy this template to `agents/personas/{domain}/{handle}.md` to create a new persona.

---

```markdown
# Persona: @{handle}

## Identity
- **Handle:** @{handle}
- **Full name:** {descriptive name}
- **Expertise:** {primary domain}
- **Modelled on:** {Real researcher name + institution}
  _{One sentence on their published philosophy or approach}_

## Perspective
{2–3 sentences on how this persona characteristically approaches problems.
What lens do they apply? What do they notice first?}

## Strengths
- {What they are best at}
- {Second strength}
- {Third strength}

## Blind spots (cross-check with)
- {Limitation 1} → cross-check with @{other_persona}
- {Limitation 2}

## Favourite questions
- "Have you considered the null hypothesis here?"
- "What is the simplest mechanistic explanation?"
- "Which patients would this NOT work for?"
- {Add characteristic questions}

## System Prompt

You are {handle}, a research collaborator modelled on the intellectual approach of {real researcher}.

Your expertise: {expertise area}.

Your characteristic perspective: {how they think}.

In every interaction:
- {Behavioural instruction 1}
- {Behavioural instruction 2}
- {Behavioural instruction 3}

When you identify a weakness in reasoning or evidence, name it directly.
When you generate a hypothesis, rate it: Novelty (1-10), Feasibility (1-10), Impact (1-10).
Always suggest what additional evidence would change your assessment.
```
PDES

  write_file "$R/architecture/04_agents/COLLABORATION_PATTERNS.md"
  cat > "$R/architecture/04_agents/COLLABORATION_PATTERNS.md" << 'COLLAB'
# Agent Collaboration Patterns

## Pattern 1: The Symposium
**Purpose:** Evaluating a hypothesis from multiple expert perspectives

1. State the hypothesis clearly
2. Activate each relevant persona in turn
3. Each gives: Assessment · Strengths · Weaknesses · What evidence would change their view
4. Note where personas agree (strong signal) and diverge (identifies what to investigate next)
5. Log synthesis in HYPOTHESIS_LOG.md

## Pattern 2: The Relay
**Purpose:** Deep literature review on a complex topic

1. @literature_reviewer maps the landscape — key papers, main camps, open debates
2. Domain specialist persona dives deep on the 3–5 most important papers
3. @devil_advocate searches for counter-evidence and methodological flaws
4. Researcher synthesises into a HYPOTHESIS_LOG or literature/summaries/ document

## Pattern 3: The Build
**Purpose:** Designing a rigorous experimental approach

1. @mechanist proposes mechanism-based experimental design
2. @statistician adds power calculation and statistical design
3. @clinician adds translational and patient-relevance considerations
4. @devil_advocate stress-tests the design
5. Researcher finalises and logs in experiments/active/

## Pattern 4: The Pre-mortem
**Purpose:** Finding failure modes before committing to an approach

Prompt: "Assume this project/experiment/hypothesis completely failed.
It is 2 years from now. What went wrong?"

Run with @devil_advocate and @statistician.
Log identified risks in DECISION_LOG.md.
COLLAB

  write_file "$R/architecture/05_technology/TOOL_REGISTRY.md"
  cat > "$R/architecture/05_technology/TOOL_REGISTRY.md" << 'TOOLS'
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
TOOLS

  write_file "$R/architecture/05_technology/MCP_ARCHITECTURE.md"
  cat > "$R/architecture/05_technology/MCP_ARCHITECTURE.md" << 'MCPARCH'
# MCP Architecture

## System Diagram

```
┌──────────────────────────────────────────────────────────────┐
│  ZED EDITOR                                                  │
│                                                              │
│  ┌──────────────────────┐  ┌──────────────────────────────┐ │
│  │  Agent Panel          │  │  Cline / Kilocode           │ │
│  │  Claude Sonnet 4.6    │  │  Claude Sonnet 4.6          │ │
│  │  (deep_reasoning)     │  │  (data_analysis, writing…)  │ │
│  └──────────┬───────────┘  └──────────────┬───────────────┘ │
└─────────────┼────────────────────────────┼─────────────────┘
              │ MCP Protocol (stdio/HTTP)   │
              ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│  BIOMEDICAL MCP SERVERS                                     │
│  BioMCP · PubMed · UniProt · ChEMBL · NCBI · BioThings    │
│  BioOntology                                                │
├─────────────────────────────────────────────────────────────┤
│  INFRASTRUCTURE MCP SERVERS                                 │
│  Qdrant (vectors) · Neo4j (graphs) · Memory · Filesystem   │
│  GitHub · Sequential Thinking                              │
└──────────────┬──────────────────────────┬──────────────────┘
               │                          │
    ┌──────────▼──────────┐   ┌──────────▼──────────┐
    │  Public APIs         │   │  Local Databases     │
    │  ClinicalTrials.gov  │   │  Qdrant (vectors)    │
    │  PubMed / PMC        │   │  Neo4j (graph)       │
    │  UniProt             │   │  Memory (JSON)       │
    │  ChEMBL              │   └─────────────────────┘
    │  NCBI, BioThings     │
    └─────────────────────┘
```

## Activating an MCP Server in Zed

1. Install the server (see `.config/mcp/mcp_registry.json`)
2. Add its `zed_config` block to `~/.config/zed/settings.json` under `context_servers`
3. Restart Zed
4. The server's tools appear in the Agent panel tool list

## Adding API Keys

1. Copy `.env.example` to `.env`
2. Fill in keys
3. Reference via environment variables in the MCP config blocks
MCPARCH

  write_file "$R/architecture/05_technology/INFRASTRUCTURE.md"
  cat > "$R/architecture/05_technology/INFRASTRUCTURE.md" << 'INFRA'
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
INFRA

  # ── pyproject.toml (uv project) ───────────────────────────────
  write_file "$R/pyproject.toml"
  cat > "$R/pyproject.toml" << PYPROJECT
[project]
name = "$(echo $REPO | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
version = "0.1.0"
description = "$TITLE — AI-augmented biomedical research"
readme = "README.md"
requires-python = ">=3.11"

dependencies = [
    "marimo[recommended]>=0.23",
    "pandas>=2.0",
    "numpy>=1.26",
    "scipy>=1.12",
    "statsmodels>=0.14",
    "matplotlib>=3.8",
    "plotly>=5.20",
    "altair>=5.4",
    "seaborn>=0.13",
    "biopython>=1.83",
    "requests>=2.31",
    "httpx>=0.27",
    "qdrant-client>=1.9",
    "py2neo>=2021.2",
    "ollama>=0.3",
    "python-dotenv>=1.0",
    "rich>=13.7",
    "loguru>=0.7",
    "pydantic>=2.7",
    "duckdb>=1.0",
    "polars>=1.0",
    "scikit-learn>=1.5",
]

[tool.marimo]
# Marimo notebook settings
[tool.marimo.runtime]
auto_instantiate = true

[tool.uv]
dev-dependencies = [
    "pytest>=8.0",
    "ruff>=0.4",
]
PYPROJECT

  # ── .marimo.toml ────────────────────────────────────────────────
  write_file "$R/.marimo.toml"
  cat > "$R/.marimo.toml" << 'MARIMOCONFIG'
[display]
theme = "dark"
cell_output = "below"

[runtime]
auto_instantiate = true
pytests_enabled = true

[save]
autosave = "after_delay"
autosave_delay = 1
format_on_save = true

[completion]
coplilot = false
activate_on_typing = true
MARIMOCONFIG

  # ── Starter marimo notebook ──────────────────────────────────────
  write_file "$R/code/marimo/explore.py"
  cat > "$R/code/marimo/explore.py" << NOTEBOOK
import marimo

__generated_with = "0.23.5"
app = marimo.App(width="medium", title="$TITLE — Explorer")

@app.cell
def __(mo):
    mo.md("""
    # $TITLE — Research Explorer

    **Notebook:** Interactive exploration environment
    **Run:** \`uvx marimo edit --sandbox code/marimo/explore.py\`

    > This is a [marimo](https://marimo.io) reactive notebook.
    > Every cell is pure Python, tracked in git, and executes reactively.
    """)
    return

@app.cell
def __():
    import marimo as mo
    import os
    from pathlib import Path
    from dotenv import load_dotenv
    load_dotenv(Path("../../.env") if Path("../../.env").exists() else Path(".env"))
    return mo, os, Path, load_dotenv

@app.cell
def __(mo):
    mo.md("## Environment Check")
    return

@app.cell
def __(mo, os):
    checks = {
        "NCBI API Key": "set" if os.getenv("NCBI_API_KEY") else "not set",
        "BioPortal API Key": "set" if os.getenv("BIOPORTAL_API_KEY") else "not set",
        "Anthropic API Key": "set" if os.getenv("ANTHROPIC_API_KEY") else "not set",
        "Ollama": "running" if __import__('subprocess').run(['ollama', 'list'], capture_output=True).returncode == 0 else "not running",
    }
    mo.table([
        {"Service": k, "Status": v}
        for k, v in checks.items()
    ])
    return checks,

@app.cell
def __(mo):
    mo.md("## Quick BioMCP Search")
    return

@app.cell
def __(mo):
    query = mo.ui.text(placeholder="e.g. BRAF V600E", label="Search BioMCP")
    query
    return query,

@app.cell
def __(mo, query):
    import subprocess, json
    if query.value:
        result = subprocess.run(
            ["biomcp", "search", "article", "-q", query.value, "--limit", "5"],
            capture_output=True, text=True
        )
        mo.md(result.stdout if result.returncode == 0 else f"Error: {result.stderr}")
    else:
        mo.md("*Enter a search term above to query BioMCP*")
    return result, subprocess, json

if __name__ == "__main__":
    app.run()
NOTEBOOK

  # ── README.md update for marimo section ─────────────────────────
  # (already created above — no change needed)

  log_done "Common scaffold complete: $REPO"
}

# ================================================================
#  DOMAIN-SPECIFIC: ClinTrials
# ================================================================
build_clintrials() {
  local R="$CLONES_DIR/ClinTrials"
  echo -e "\n${CYN}  ↳  ClinTrials — domain-specific additions${NC}"

  mkd "$R/data/external/clinicaltrials_gov"
  mkd "$R/data/external/aact"
  mkd "$R/data/external/pubmed"
  mkd "$R/data/external/fda"
  mkd "$R/data/external/who_ictrp"
  mkd "$R/knowledge/graphs/trial_networks"
  mkd "$R/knowledge/graphs/drug_disease_map"
  mkd "$R/knowledge/graphs/patient_populations"
  mkd "$R/knowledge/graphs/outcome_measures"
  mkd "$R/knowledge/graphs/regulatory_landscape"
  mkd "$R/agents/personas/clinical_investigators"
  mkd "$R/agents/personas/biostatisticians"
  mkd "$R/agents/personas/regulatory_experts"
  mkd "$R/agents/personas/patient_advocates"

  write_file "$R/agents/personas/clinical_investigators/README.md"
  cat > "$R/agents/personas/clinical_investigators/README.md" << 'DOM'
# Clinical Investigator Personas

Modelled on the rigorous, patient-centred perspective of leading trial methodologists.

## Personas to develop

### @gordonguyatt_perspective
- **Modelled on:** Gordon Guyatt (McMaster) — father of evidence-based medicine, GRADE framework
- **Perspective:** Patient values and preferences matter as much as effect sizes. Rigorous evidence grading. Clinical significance over statistical significance.
- **Strengths:** Evidence quality assessment, clinical relevance, GRADE application
- **Prompt file:** gordonguyatt_perspective.md *(create using PERSONA_DESIGN.md template)*

### @rct_methodologist
- **Modelled on:** Doug Altman + CONSORT framework perspective
- **Perspective:** Randomisation quality, allocation concealment, outcome reporting bias, CONSORT compliance
- **Strengths:** Trial design critique, bias identification, reporting standards

### @adaptive_trialist
- **Modelled on:** Donald Berry (MD Anderson) — Bayesian adaptive trial design
- **Perspective:** Adaptive designs, Bayesian endpoints, response-adaptive randomisation
- **Strengths:** Innovative trial design, efficiency, biomarker-stratified approaches
DOM

  write_file "$R/agents/personas/biostatisticians/README.md"
  cat > "$R/agents/personas/biostatisticians/README.md" << 'DOM'
# Biostatistician Personas

## Personas to develop

### @frequentist_stat
- **Perspective:** Classical NHST, power calculations, multiplicity corrections, pre-registration
- **Strengths:** Sample size, Type I/II error, multiple comparisons, survival analysis

### @bayesian_stat
- **Modelled on:** Andrew Gelman perspective
- **Perspective:** Prior specification, credible intervals, posterior predictive checks, adaptive designs
- **Strengths:** Small samples, prior elicitation, hierarchical models
DOM

  write_file "$R/knowledge/graphs/trial_networks/README.md"
  cat > "$R/knowledge/graphs/trial_networks/README.md" << 'DOM'
# Trial Networks Knowledge Graph

Maps relationships between trials, interventions, conditions, sponsors and outcomes.

## Node types
- **Trial** (nct_id, phase, status, start_date, primary_completion_date, n_enrolled)
- **Intervention** (name, type, dosage, route)
- **Condition** (mesh_term, icd10)
- **Outcome** (name, type: primary/secondary, timepoint, measure_type)
- **Sponsor** (name, type: industry/academic/NIH, country)
- **Site** (name, country, n_enrolled)

## Relationship types
- TESTS: Trial → Intervention
- STUDIES: Trial → Condition
- MEASURES: Trial → Outcome
- SPONSORED_BY: Trial → Sponsor
- CONDUCTED_AT: Trial → Site
- FOLLOWS_FROM: Trial → Trial  (phase I → II → III progression)
- COMPARED_TO: Trial → Trial  (network meta-analysis links)
DOM

  write_file "$R/data/external/clinicaltrials_gov/README.md"
  cat > "$R/data/external/clinicaltrials_gov/README.md" << 'DOM'
# ClinicalTrials.gov Data

Data retrieved from ClinicalTrials.gov via BioMCP or the v2 REST API.

## BioMCP commands
```bash
biomcp search trial -q "your disease or drug query"
biomcp get trial NCT04280705
```

## Direct API
- Base URL: https://clinicaltrials.gov/api/v2/studies
- Docs: https://clinicaltrials.gov/data-api/api

## File naming convention
{NCT_ID}_{YYYY-MM-DD}.json

## AACT (full database download)
Aggregate Analysis of ClinicalTrials.gov: https://aact.ctti-clinicaltrials.org
Provides PostgreSQL dump of the full registry — useful for bulk analysis.
DOM
}

# ================================================================
#  DOMAIN-SPECIFIC: mAb
# ================================================================
build_mab() {
  local R="$CLONES_DIR/mAb"
  echo -e "\n${CYN}  ↳  mAb — domain-specific additions${NC}"

  mkd "$R/data/external/uniprot"
  mkd "$R/data/external/pdb"
  mkd "$R/data/external/imgt"
  mkd "$R/data/external/chembl"
  mkd "$R/data/external/bindingdb"
  mkd "$R/data/external/thera_sab_db"
  mkd "$R/knowledge/graphs/antibody_target_network"
  mkd "$R/knowledge/graphs/epitope_map"
  mkd "$R/knowledge/graphs/clinical_pipeline"
  mkd "$R/knowledge/graphs/mechanism_of_action"
  mkd "$R/knowledge/graphs/sequence_space"
  mkd "$R/agents/personas/immunologists"
  mkd "$R/agents/personas/structural_biologists"
  mkd "$R/agents/personas/pharmacologists"
  mkd "$R/agents/personas/antibody_engineers"

  write_file "$R/agents/personas/immunologists/README.md"
  cat > "$R/agents/personas/immunologists/README.md" << 'DOM'
# Immunologist Personas

## Personas to develop

### @fc_biology_expert
- **Modelled on:** Jeffrey Ravetch perspective (Rockefeller — Fc receptor biology)
- **Perspective:** Fc receptor engagement is as important as antigen binding. Isotype selection, glycosylation and FcγR affinity determine in vivo efficacy.
- **Strengths:** ADCC, CDC, ADCP, FcRn biology, half-life engineering

### @bispecific_pioneer
- **Perspective:** Bispecific and multispecific formats — T-cell engagers, dual-targeting, conditional activity
- **Strengths:** Format selection (IgG-like vs fragments), manufacturability, avidity engineering

### @checkpoint_specialist
- **Perspective:** Immune checkpoint biology, combination strategies, resistance mechanisms
- **Strengths:** PD-1/PD-L1/CTLA-4 biology, TME interactions, biomarker-stratified approaches
DOM

  write_file "$R/agents/personas/structural_biologists/README.md"
  cat > "$R/agents/personas/structural_biologists/README.md" << 'DOM'
# Structural Biology Personas

## Personas to develop

### @structuralist
- **Perspective:** CDR loop analysis, paratope-epitope contacts, cryo-EM and X-ray interpretation
- **Strengths:** Binding mode analysis, cross-reactivity prediction, humanisation guidance

### @computational_folder
- **Perspective:** AlphaFold2/3 integration, homology modelling, antibody-antigen docking
- **Strengths:** Structure prediction, developability flags (aggregation, liabilities), sequence-based engineering
DOM

  write_file "$R/knowledge/graphs/epitope_map/README.md"
  cat > "$R/knowledge/graphs/epitope_map/README.md" << 'DOM'
# Epitope Map Knowledge Graph

Maps antibody binding sites to antigen surfaces and structural features.

## Node types
- **Antibody** (name, isotype, format, origin: human/humanised/murine, INN)
- **Antigen** (uniprot_id, name, organism, molecular_weight)
- **Epitope** (residues, type: linear/conformational, domain, accessible_in_vivo)
- **CDR** (sequence, length, kabat_numbering, antibody)
- **Structure** (pdb_id, method: xray/cryo-em, resolution)

## Relationship types
- BINDS: Antibody → Antigen (kd_nm, kon, koff)
- CONTACTS: CDR → Epitope residues
- LOCATED_ON: Epitope → Antigen domain
- COMPETES_WITH: Antibody → Antibody (bin: same/different epitope)
- RESOLVED_IN: Antibody:Antigen complex → Structure
DOM

  write_file "$R/data/external/uniprot/README.md"
  cat > "$R/data/external/uniprot/README.md" << 'DOM'
# UniProt Data

Protein sequence and annotation data for antibody targets and antibody components.

## Via MCP
```
UniProt MCP server — see .config/mcp/biomedical/uniprot.json
```

## Via BioMCP
```bash
biomcp get protein {uniprot_id}
biomcp search protein -q "CD20 human"
```

## Key data to collect
- Target antigen: canonical sequence, isoforms, domains, PTMs
- Clinical variants affecting epitopes
- Tissue and cancer expression levels (via Protein Atlas)
- Interacting proteins (for bispecific target selection)

## File naming convention
{UNIPROT_ID}_{protein_name}_{YYYY-MM-DD}.json
DOM
}

# ================================================================
#  DOMAIN-SPECIFIC: FlourTag
# ================================================================
build_flourtag() {
  local R="$CLONES_DIR/FlourTag"
  echo -e "\n${CYN}  ↳  FlourTag — domain-specific additions${NC}"

  mkd "$R/data/external/pubchem"
  mkd "$R/data/external/chembl"
  mkd "$R/data/external/protein_atlas"
  mkd "$R/data/external/cell_image_library"
  mkd "$R/data/external/fluorophore_db"
  mkd "$R/data/external/fpbase"
  mkd "$R/knowledge/graphs/probe_target_network"
  mkd "$R/knowledge/graphs/cancer_marker_map"
  mkd "$R/knowledge/graphs/imaging_protocols"
  mkd "$R/knowledge/graphs/spectral_profiles"
  mkd "$R/knowledge/graphs/selectivity_map"
  mkd "$R/agents/personas/cancer_biologists"
  mkd "$R/agents/personas/fluorescence_chemists"
  mkd "$R/agents/personas/imaging_specialists"
  mkd "$R/agents/personas/medicinal_chemists"

  write_file "$R/agents/personas/cancer_biologists/README.md"
  cat > "$R/agents/personas/cancer_biologists/README.md" << 'DOM'
# Cancer Biology Personas

## Personas to develop

### @tme_specialist
- **Modelled on:** Immunotherapy / tumour microenvironment systems perspective
- **Perspective:** The tumour microenvironment determines probe accessibility. Hypoxia, acidity, immune infiltration and stromal composition all affect probe behaviour in vivo.
- **Strengths:** Biomarker contextualisation, in vivo relevance, resistance mechanisms

### @biomarker_validator
- **Perspective:** Clinical utility of biomarkers — sensitivity, specificity, PPV/NPV in real populations
- **Strengths:** Diagnostic rigor, clinical decision threshold analysis, regulatory pathway thinking
- **Favourite question:** "Would a positive result actually change clinical management?"

### @cancer_genomics
- **Perspective:** Mutation landscape, driver vs passenger genes, heterogeneity, liquid biopsy
- **Strengths:** Target validation, patient stratification, resistance mutation monitoring
DOM

  write_file "$R/agents/personas/fluorescence_chemists/README.md"
  cat > "$R/agents/personas/fluorescence_chemists/README.md" << 'DOM'
# Fluorescence Chemistry Personas

## Personas to develop

### @photophysics_first
- **Perspective:** Photophysical properties determine everything else. Start with quantum yield, Stokes shift, photostability, then worry about bioconjugation.
- **Strengths:** Spectral design, FRET pair selection, photobleaching analysis, environment-sensitive probes

### @bioorthogonal_chemist
- **Modelled on:** Carolyn Bertozzi perspective — bioorthogonal chemistry, minimal biological perturbation
- **Perspective:** The tag should not perturb the biology. Click chemistry, inverse-demand Diels-Alder, tetrazine ligation.
- **Strengths:** Metabolic labelling, in vivo click reactions, two-step pretargeting strategies

### @targeted_delivery
- **Perspective:** Getting the probe to the right place in vivo — antibody conjugates, small molecule targeting, nanoparticle delivery
- **Strengths:** Probe-to-linker-to-targeting-vector design, PK/PD of imaging agents
DOM

  write_file "$R/agents/personas/imaging_specialists/README.md"
  cat > "$R/agents/personas/imaging_specialists/README.md" << 'DOM'
# Imaging Specialist Personas

## Personas to develop

### @microscopy_expert
- **Perspective:** Instrument capabilities and limitations define what you can measure. Resolution, sensitivity, speed and phototoxicity are the constraints.
- **Strengths:** Confocal, TIRF, STORM/PALM, light-sheet — choosing right modality, optimising acquisition

### @in_vivo_imager
- **Perspective:** In vivo optical imaging — depth penetration, tissue autofluorescence, NIR-II window
- **Strengths:** Whole-animal imaging, tumour window chambers, intravital microscopy
DOM

  write_file "$R/knowledge/graphs/spectral_profiles/README.md"
  cat > "$R/knowledge/graphs/spectral_profiles/README.md" << 'DOM'
# Spectral Profiles Knowledge Graph

Maps fluorescent probes to photophysical properties and imaging system compatibility.

## Node types
- **Probe** (name, smiles, pubchem_cid, class: small_mol/protein/nanoparticle)
- **Fluorophore** (excitation_max_nm, emission_max_nm, stokes_shift_nm, quantum_yield, extinction_coefficient, photostability_score)
- **CancerTarget** (name, uniprot_id, cancer_types_expressed, subcellular_location)
- **ImagingSystem** (type: confocal/widefield/TIRF/in_vivo, laser_lines_nm, filter_sets)
- **ImagingProtocol** (name, fixed_or_live, permeabilisation, blocking)

## Relationship types
- LABELS: Probe → CancerTarget (kd_nm, labelling_efficiency, conditions)
- HAS_FLUOROPHORE: Probe → Fluorophore
- COMPATIBLE_WITH: Fluorophore → ImagingSystem
- SPECTRALLY_OVERLAPS: Fluorophore ↔ Fluorophore (for multiplexing conflicts)
- EXPRESSED_IN: CancerTarget → CancerType (expression_level, source: protein_atlas)
- IMAGED_WITH: Probe → ImagingProtocol (reference_pmid)
DOM

  write_file "$R/data/external/fpbase/README.md"
  cat > "$R/data/external/fpbase/README.md" << 'DOM'
# FPbase — Fluorescent Protein Database

Comprehensive spectral and photophysical data for fluorescent proteins and small molecule dyes.

## Access
- Web: https://www.fpbase.org
- API: https://www.fpbase.org/api/
- Spectra viewer: https://www.fpbase.org/spectra/

## Data to collect
- Excitation / emission spectra (raw)
- Quantum yield, extinction coefficient, brightness
- Photostability (bleaching half-time)
- pKa (relevant for lysosomal / acidic compartment probes)
- Oligomeric state (monomer preferred for fusion tags)

## File naming convention
{fluorophore_name}_{YYYY-MM-DD}.json
DOM
}

# ================================================================
#  MAIN
# ================================================================
echo ""
echo -e "${YLW}════════════════════════════════════════════════════════${NC}"
echo -e "${YLW}  🔬  Research Repository Scaffold Builder              ${NC}"
echo -e "${YLW}  mvz-axo · michael@axolotl.partners                   ${NC}"
echo -e "${YLW}════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Working from: $CLONES_DIR"
echo ""

build_common "ClinTrials" "ClinTrials Research" \
  "AI-augmented research into clinical trials data, evidence synthesis, trial networks and drug-disease relationships."

build_common "mAb" "Monoclonal Antibodies Research" \
  "AI-augmented research into monoclonal antibody development, target biology, epitope mapping and clinical pipelines."

build_common "FlourTag" "Fluorescent Cancer Tagging Research" \
  "AI-augmented research into fluorescent probe design, cancer biomarker targeting and imaging protocols."

build_clintrials
build_mab
build_flourtag

# ── Git: initial commits ──────────────────────────────────────
echo ""
log_head "Git — staging and committing all three repos"

for REPO in ClinTrials mAb FlourTag; do
  cd "$CLONES_DIR/$REPO"
  git add .
  git commit -m "🔬 feat: initial research scaffold

TOGAF-lite research architecture for AI-augmented biomedical research.

Structure:
- .config/  — MCP registry (7 biomedical + 5 infra servers), LLM profiles, DB configs
- architecture/ — 5-layer TOGAF-lite docs (research/data/knowledge/agents/technology)
- data/ + literature/ + knowledge/ + agents/ + code/ + experiments/ + reports/
- Domain-specific knowledge graph schemas, data source directories, persona starters

LLM profiles: deep_reasoning · literature_review · data_analysis · hypothesis_gen · scientific_writing
MCP servers configured: BioMCP · PubMed · UniProt · ChEMBL · NCBI · BioThings · BioOntology · Qdrant · Neo4j · Memory · GitHub · Filesystem"
  log_done "$REPO committed"
  cd "$CLONES_DIR"
done

# ── Push to GitHub ────────────────────────────────────────────
echo ""
log_head "Pushing all three repos to GitHub"

for REPO in ClinTrials mAb FlourTag; do
  cd "$CLONES_DIR/$REPO"
  git branch -M main
  git push -u origin main
  log_done "$REPO pushed to github.com/mvz-axo/$REPO"
  cd "$CLONES_DIR"
done

# ── Summary ───────────────────────────────────────────────────
echo ""
echo -e "${YLW}════════════════════════════════════════════════════════${NC}"
echo -e "${GRN}  ✅  Scaffold complete!${NC}"
echo -e "${YLW}════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Your repos are live at:"
echo "    https://github.com/mvz-axo/ClinTrials"
echo "    https://github.com/mvz-axo/mAb"
echo "    https://github.com/mvz-axo/FlourTag"
echo ""
echo "  Recommended next steps:"
echo ""
echo "  1. Install BioMCP (your first research tool):"
echo "     pip install biomcp-cli"
echo "     biomcp health --apis-only"
echo ""
echo "  2. Get free API keys (takes 2 min each):"
echo "     NCBI:      https://www.ncbi.nlm.nih.gov/account"
echo "     BioPortal: https://bioportal.bioontology.org/accounts/new"
echo ""
echo "  3. Open each repo in Zed:"
echo "     zed ~/Clones/ClinTrials"
echo ""
echo "  4. Read your first architecture doc:"
echo "     cat ~/Clones/ClinTrials/architecture/05_technology/MCP_ARCHITECTURE.md"
echo ""
echo -e "${YLW}════════════════════════════════════════════════════════${NC}"
