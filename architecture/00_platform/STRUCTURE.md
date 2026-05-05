# mvz-axo Research Platform — Canonical Directory Structure

This document defines the **fixed top-level structure** shared across all
research projects in the mvz-axo platform. Every repository follows this
layout exactly. Domain-specific content unfolds *within* this structure —
the structure itself does not change between projects.

## The Principle

```
Fixed structure (same everywhere)       Domain content (unfolds within it)
────────────────────────────────        ────────────────────────────────
architecture/01_research/               ← VISION.md content differs
architecture/03_knowledge/              ← GRAPH_SCHEMA.md nodes differ
crates/                                 ← crate names + types differ
data/external/                          ← data sources differ
knowledge/graphs/                       ← graph schemas differ
agents/personas/                        ← expert roles differ
```

## Full Directory Map

```
<ProjectName>/
│
│   ── Root documents ──────────────────────────────────────────────────────
├── README.md                    Project overview and quick-start
├── ARCHITECTURE.md              One-page architecture summary (links to architecture/)
├── RESEARCH_PLAN.md             Current goals, methodology, milestones
├── AGENT_ROSTER.md              AI researcher personas in use
├── DATA_SOURCES.md              Catalog of all data sources used
├── HYPOTHESIS_LOG.md            Hypotheses: proposed → tested → confirmed/rejected
├── DECISION_LOG.md              Key design and methodology decisions + rationale
├── CHANGELOG.md                 Progress log and milestones
│
│   ── Build + runtime ─────────────────────────────────────────────────────
├── Cargo.toml                   Rust Cargo workspace (members: crates/*)
├── rust-toolchain.toml          Pinned: stable channel
├── .env.example                 ← COMPREHENSIVE key template (this repo's copy)
├── .env                         ← Your filled-in secrets (git-ignored)
├── .gitignore
│
│   ── Architecture documentation (TOGAF-lite) ─────────────────────────────
├── architecture/
│   ├── 00_platform/             SHARED: platform-level docs (same across all repos)
│   │   ├── STRUCTURE.md         ← This file
│   │   ├── MCP_LAYER.md         All MCP servers: what they do, how to activate
│   │   ├── RUST_WORKSPACE.md    Cargo workspace layout + how to add crates
│   │   └── ONBOARDING.md        New contributor or new project setup guide
│   │
│   ├── 01_research/             DOMAIN: research identity
│   │   ├── VISION.md            Long/medium/short-term research vision
│   │   └── METHODOLOGY.md       AI collaboration framework + quality controls
│   │
│   ├── 02_data/                 DOMAIN: data layer
│   │   ├── DATA_SOURCES.md      Authoritative source registry
│   │   └── DATA_PIPELINE.md     How data flows from source → processed → embedded
│   │
│   ├── 03_knowledge/            DOMAIN: knowledge representation
│   │   ├── GRAPH_SCHEMA.md      Node + relationship types for this domain
│   │   └── EMBEDDING_STRATEGY.md  Chunking, models, collection naming conventions
│   │
│   ├── 04_agents/               DOMAIN: AI collaborator design
│   │   ├── AGENT_FRAMEWORK.md   How agent personas are structured + invoked
│   │   ├── PERSONA_DESIGN.md    Template for creating new personas
│   │   └── COLLABORATION_PATTERNS.md  Symposium, Relay, Build, Code Review patterns
│   │
│   └── 05_technology/           SHARED+DOMAIN: infrastructure
│       ├── INFRASTRUCTURE.md    Current tech stack status (update as things change)
│       ├── MCP_ARCHITECTURE.md  MCP system diagram + Zed activation guide
│       └── TOOL_REGISTRY.md     All tools with install commands + status
│
│   ── Rust crates ─────────────────────────────────────────────────────────
├── crates/
│   ├── <domain>-core/           Strongly-typed domain model (no I/O, no async)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── error.rs
│   │       └── <entity>.rs      One file per major domain entity
│   │
│   ├── <domain>-ingest/         Typed async clients for external APIs
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── error.rs
│   │       └── <source>.rs      One file per data source
│   │
│   ├── <domain>-mcp/            Custom MCP tool server for this domain
│   │   └── src/
│   │       ├── main.rs          Binary entry point (run_stdio_server)
│   │       ├── lib.rs
│   │       ├── server.rs        McpToolServer impl
│   │       └── tools.rs         ToolDefinition list
│   │
│   └── <domain>-cli/            Research CLI binary
│       └── src/
│           ├── main.rs
│           └── commands/
│               ├── mod.rs
│               ├── ingest.rs
│               └── search.rs
│
│   ── Runtime configuration ───────────────────────────────────────────────
├── .config/
│   ├── mcp/                     MCP server registry + launch scripts
│   │   ├── mcp_registry.json    Master registry of all MCP servers + zed_config
│   │   ├── arsenal.env          Shared env vars for arsenal binaries
│   │   ├── run-embedding.sh     Launch arsenal-mcp-embedding
│   │   ├── run-rss-reader.sh    Launch arsenal-mcp-rss-reader
│   │   └── run-logseq.sh        Launch arsenal-mcp-logseq (graph: knowledge/logseq/)
│   │
│   ├── llm/                     LLM routing configuration
│   │   ├── model_registry.json  Available models and their capabilities
│   │   └── profiles/            Task-specific model selection profiles
│   │       ├── deep_reasoning.json
│   │       ├── literature_review.json
│   │       ├── data_analysis.json
│   │       ├── hypothesis_gen.json
│   │       └── scientific_writing.json
│   │
│   ├── databases/               Database connection configuration
│   │   ├── qdrant.yaml          Qdrant connection + collection defaults
│   │   └── neo4j.yaml           Neo4j connection + schema
│   │
│   └── unsloth/                 Unsloth Studio configuration
│       └── launch-studio.sh     Launch script (Studio runs as systemd service)
│
│   ── Research data ──────────────────────────────────────────────────────
├── data/                        (bulk data git-ignored; structure versioned)
│   ├── external/                Downloaded from public data sources
│   │   └── <source-name>/       e.g. clinicaltrials_gov/, uniprot/, fpbase/
│   │       └── README.md        What data lives here, how to obtain it, naming conv.
│   ├── raw/                     Unprocessed local/proprietary data
│   ├── processed/               Cleaned, normalised, transformed (never modify raw)
│   ├── embedded/                Qdrant collection snapshots for backup/transfer
│   └── databases/               Local database files (Neo4j data, SQLite)
│
│   ── Knowledge artifacts ────────────────────────────────────────────────
├── knowledge/
│   ├── logseq/                  Logseq knowledge graph (served by arsenal-mcp-logseq)
│   │   ├── pages/               Concept pages in Markdown
│   │   ├── journals/            Daily research notes
│   │   ├── assets/              Images and attachments
│   │   └── logseq/              Logseq internal config
│   │       └── config.edn
│   ├── ontologies/              Domain ontology files (OWL, OBO, JSON-LD)
│   └── graphs/                  Domain knowledge graph definitions
│       └── <graph-name>/        e.g. epitope_map/, spectral_profiles/, trial_networks/
│           └── README.md        Node types, relationship types, data sources
│
│   ── Literature ────────────────────────────────────────────────────────
├── literature/
│   ├── pdfs/                    Downloaded papers (git-ignored, use git-lfs if needed)
│   ├── notes/                   Researcher annotations + AI-generated summaries
│   └── reading_list.md          Curated and prioritised reading list
│
│   ── AI researcher personas ─────────────────────────────────────────────
├── agents/
│   ├── personas/                Persona definitions + system prompts
│   │   └── <role>/              e.g. immunologists/, cancer_biologists/
│   │       └── README.md        Expertise, modelled-on, prompt file location
│   └── conversations/           Archived agent conversations (for audit trail)
│
│   ── Experiments ────────────────────────────────────────────────────────
├── experiments/
│   ├── active/                  Currently running experiments
│   ├── completed/               Finished with documented results
│   └── archived/                Superseded or abandoned (kept for reference)
│
│   ── Outputs ───────────────────────────────────────────────────────────
└── reports/
    ├── findings/                Research findings documents
    ├── visualizations/          Charts, graphs, figures
    └── publications/            Manuscript drafts
```

## What is Shared vs Domain-Specific

| Area | Shared (same across all repos) | Domain-specific (unfolds within) |
|------|-------------------------------|----------------------------------|
| Root documents | File names + structure | Content |
| architecture/00_platform/ | Entire section | — |
| architecture/01–04/ | Section structure + file names | All content |
| architecture/05_technology/ | INFRASTRUCTURE.md structure | Status values; TOOL_REGISTRY additions |
| Cargo.toml | Workspace layout + kask deps | Crate names; domain workspace deps |
| crates/ | Crate role pattern (core/ingest/mcp/cli) | Types, APIs, tools |
| .config/mcp/mcp_registry.json | All platform MCP servers | Domain-specific custom MCP entry |
| .config/llm/ | All profiles + model registry | Model preferences per domain |
| .env.example | All keys + structure | Project name; QDRANT path; RSS feeds |
| data/external/ | Directory convention + README pattern | Source names + content |
| knowledge/logseq/ | Directory structure | Page content |
| knowledge/graphs/ | README convention | Graph schemas + data |
| agents/personas/ | Directory pattern + README template | Expert roles + prompts |

## Adding a New Research Repository

1. Copy the scaffold from an existing repo (preserve all fixed structure)
2. Update `README.md`, `RESEARCH_PLAN.md` for the new domain
3. Fill in `architecture/01_research/VISION.md` and `METHODOLOGY.md`
4. Define `architecture/03_knowledge/GRAPH_SCHEMA.md` for the domain
5. Rename `crates/<old-domain>-*` → `crates/<new-domain>-*`
6. Update `Cargo.toml` workspace member names
7. Add domain-specific data sources to `data/external/`
8. Design initial knowledge graph in `knowledge/graphs/`
9. Copy `.env.example` and update project name + QDRANT path + RSS feeds
10. Update `architecture/05_technology/TOOL_REGISTRY.md` if new tools are added

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Rust crates | `<domain>-<role>` kebab-case | `ct-core`, `mab-ingest`, `flourtag-mcp` |
| Qdrant collections | `<domain>_<corpus>` snake_case | `ct_pubmed`, `mab_literature` |
| Neo4j databases | `<Domain>` PascalCase | `ClinTrials`, `Mab`, `FlourTag` |
| Data files | `<identifier>_<YYYY-MM-DD>.<ext>` | `NCT04440735_2026-05-04.json` |
| Logseq pages | Title Case natural language | `Monoclonal Antibody Mechanisms` |
| Agent personas | `<FirstName>` singular | `Elena`, `Marcus`, `Priya` |
