#!/bin/sh
set -e

echo "=== [RMAA GitVault Engine Initializing] ==="

# 1. Background Keep-Alive Self-Ping Daemon
# Pings Render's endpoint every 13 minutes (780s) to keep free tier awake 24/7
(
  echo "[+] GitVault Keep-Alive Daemon started."
  while true; do
    sleep 780
    TARGET="${KEEP_ALIVE_URL:-http://127.0.0.1:3000/api/v1/version}"
    echo "[*] Keep-Alive Ping -> ${TARGET}"
    wget -qO- --timeout=15 "${TARGET}" > /dev/null 2>&1 || true
  done
) &

# 2. Launch Rootless Gitea Engine with Dynamic Environment Variables
exec /usr/local/bin/gitea web
