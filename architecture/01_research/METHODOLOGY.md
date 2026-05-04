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
