# Tool Registry

## MCP Servers

Full configs in `.config/mcp/mcp_registry.json`

| Server | Purpose | Status | Install |
|---|---|---|---|
| **BioMCP** | Trials, PubMed, genes, variants, drugs | 🔲 Install needed | `pip install biomcp-cli` |
| **PubMed MCP** | 36M+ citations, full text, MeSH | 🔲 Install needed | npm (Augmented Nature) |
| **UniProt MCP** | Proteins, structures, pathways | 🔲 Install needed | npm (Augmented Nature) |
| **ChEMBL MCP** | Drug bioactivity, ADMET | 🔲 Install needed | npm (Augmented Nature) |
| **NCBI MCP** | Genomes, sequences, taxonomy | 🔲 Install needed | npm (Augmented Nature) |
| **BioThings MCP** | 22M genes + 400M variants | 🔲 Install needed | npm (Augmented Nature) |
| **BioOntology MCP** | 1,200+ ontologies (needs API key) | 🔲 Install needed | npm (Augmented Nature) |
| **Qdrant MCP** | Vector search, semantic memory | 🔲 Install needed | `pip install uv` |
| **Neo4j MCP** | Knowledge graphs, Cypher | 🔲 Install needed | Binary from GitHub |
| **Memory MCP** | Persistent agent memory | 🔲 Install needed | npx (auto) |
| **GitHub MCP** | Repo, issues, code search | ✅ Active | Zed extension |
| **Sequential Thinking** | Structured reasoning | ✅ Active | Zed extension |
| **Filesystem MCP** | Local file read/write | 🔲 Install needed | npx (auto) |

## Python Packages (install as needed)

```bash
pip install biomcp-cli              # BioMCP CLI
pip install qdrant-client           # Qdrant Python client
pip install sentence-transformers   # Local embeddings
pip install biopython               # Bioinformatics utilities
pip install pandas numpy scipy      # Data analysis
pip install matplotlib plotly       # Visualisation
pip install py2neo                  # Neo4j Python client
pip install requests httpx          # API access
pip install jupyter                 # Notebooks
pip install openai                  # OpenAI embeddings (optional)
```

## Zed Extensions (installed)

| Extension | Purpose |
|---|---|
| Cline | AI coding agent with full file access |
| Kilocode | AI coding agent |
| dockerfile | Docker file support |
