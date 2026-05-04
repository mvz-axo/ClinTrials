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
