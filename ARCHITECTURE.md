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
