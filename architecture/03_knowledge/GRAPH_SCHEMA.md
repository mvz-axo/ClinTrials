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
