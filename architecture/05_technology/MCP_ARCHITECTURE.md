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
