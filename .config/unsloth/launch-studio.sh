#!/usr/bin/env bash
# Launch Unsloth Studio — accessible at http://192.168.18.47:8888
# Binds to all interfaces so other devices on the LAN can connect
source ~/.bashrc 2>/dev/null || true
exec unsloth studio -H 0.0.0.0 -p 8888 "$@"
