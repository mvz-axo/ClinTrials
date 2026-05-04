#!/usr/bin/env bash
set -a
source /home/mvz-axo/Clones/ClinTrials/.config/mcp/arsenal.env
# Also load project .env if it exists
[ -f /home/mvz-axo/Clones/ClinTrials/.env ] && source /home/mvz-axo/Clones/ClinTrials/.env
set +a
exec ~/.local/bin/arsenal-mcp-embedding "$@"
