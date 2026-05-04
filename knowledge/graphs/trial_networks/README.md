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
