#!/usr/bin/env bash
set -a
source /home/mvz-axo/Clones/ClinTrials/.config/mcp/arsenal.env
[ -f /home/mvz-axo/Clones/ClinTrials/.env ] && source /home/mvz-axo/Clones/ClinTrials/.env
set +a
exec ~/.local/bin/arsenal-mcp-logseq \
    --graph-path /home/mvz-axo/Clones/ClinTrials/knowledge/logseq \
    "$@"
