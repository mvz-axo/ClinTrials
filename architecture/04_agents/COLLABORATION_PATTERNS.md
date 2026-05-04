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
