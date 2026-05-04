import marimo

__generated_with = "0.23.5"
app = marimo.App(width="medium", title="ClinTrials Research — Explorer")

@app.cell
def __(mo):
    mo.md("""
    # ClinTrials Research — Research Explorer

    **Notebook:** Interactive exploration environment
    **Run:** `uvx marimo edit --sandbox code/marimo/explore.py`

    > This is a [marimo](https://marimo.io) reactive notebook.
    > Every cell is pure Python, tracked in git, and executes reactively.
    """)
    return

@app.cell
def __():
    import marimo as mo
    import os
    from pathlib import Path
    from dotenv import load_dotenv
    load_dotenv(Path("../../.env") if Path("../../.env").exists() else Path(".env"))
    return mo, os, Path, load_dotenv

@app.cell
def __(mo):
    mo.md("## Environment Check")
    return

@app.cell
def __(mo, os):
    checks = {
        "NCBI API Key": "set" if os.getenv("NCBI_API_KEY") else "not set",
        "BioPortal API Key": "set" if os.getenv("BIOPORTAL_API_KEY") else "not set",
        "Anthropic API Key": "set" if os.getenv("ANTHROPIC_API_KEY") else "not set",
        "Ollama": "running" if __import__('subprocess').run(['ollama', 'list'], capture_output=True).returncode == 0 else "not running",
    }
    mo.table([
        {"Service": k, "Status": v}
        for k, v in checks.items()
    ])
    return checks,

@app.cell
def __(mo):
    mo.md("## Quick BioMCP Search")
    return

@app.cell
def __(mo):
    query = mo.ui.text(placeholder="e.g. BRAF V600E", label="Search BioMCP")
    query
    return query,

@app.cell
def __(mo, query):
    import subprocess, json
    if query.value:
        result = subprocess.run(
            ["biomcp", "search", "article", "-q", query.value, "--limit", "5"],
            capture_output=True, text=True
        )
        mo.md(result.stdout if result.returncode == 0 else f"Error: {result.stderr}")
    else:
        mo.md("*Enter a search term above to query BioMCP*")
    return result, subprocess, json

if __name__ == "__main__":
    app.run()
