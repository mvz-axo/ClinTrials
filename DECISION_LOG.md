# Decision Log

Architectural and methodological decisions, with rationale.
Format inspired by Architecture Decision Records (ADR).

---

## DR-001: Repository scaffold design
- **Date:** 2026-05-04
- **Decision:** TOGAF-lite scaffold — artifact type at top level, domain concepts at second level
- **Rationale:** Consistent cross-repo structure; flexible domain expansion; supports knowledge graph + RAG + agent workflows from day one
- **Alternatives considered:** Flat structure; domain-first structure
- **Status:** ✅ Accepted

---

## Template

```
## DR-XXX: [Title]
- **Date:** YYYY-MM-DD
- **Decision:** What was decided
- **Rationale:** Why this option
- **Alternatives considered:**
- **Status:** ✅ Accepted | 🔄 Revised | ❌ Superseded
```
