#!/bin/bash
set -e

VAULT_DIR="/var/lib/gitea"
HF_REMOTE="https://rmaapk:${GITEA__storage__MINIO_SECRET_ACCESS_KEY}@huggingface.co/datasets/rmaapk/pgit"
SYNC_DIR="/tmp/hf_pgit_sync"

echo "[*] Initializing Git-Xet / HF Private Dataset Vault..."
mkdir -p "${SYNC_DIR}"

git config --global user.name "RMAA GitVault"
git config --global user.email "gitvault@rmaa.pk"

# 1. Pull existing dataset vault from HF if available
if [ ! -d "${SYNC_DIR}/.git" ]; then
  echo "[+] Cloning private HF dataset rmaapk/pgit into ${SYNC_DIR}..."
  git clone --depth 1 "${HF_REMOTE}" "${SYNC_DIR}" 2>/dev/null || {
    cd "${SYNC_DIR}"
    git init
    git branch -M main
    git remote add origin "${HF_REMOTE}"
  }
fi

# Restore any stored repositories & data
if [ -d "${SYNC_DIR}/repositories" ]; then
  echo "[+] Restoring repositories from HF vault into ${VAULT_DIR}/git/repositories..."
  mkdir -p "${VAULT_DIR}/git"
  cp -rn "${SYNC_DIR}/repositories" "${VAULT_DIR}/git/" || true
fi

# 2. Continuous Background Sync Daemon
echo "[+] Starting continuous HF Git-Xet sync loop (every 60s)..."
while true; do
  sleep 60
  if [ -d "${VAULT_DIR}/git/repositories" ]; then
    mkdir -p "${SYNC_DIR}/repositories"
    rsync -a --delete "${VAULT_DIR}/git/repositories/" "${SYNC_DIR}/repositories/" 2>/dev/null || cp -ru "${VAULT_DIR}/git/repositories/"* "${SYNC_DIR}/repositories/" 2>/dev/null || true
    
    cd "${SYNC_DIR}"
    if [ -n "$(git status --porcelain)" ]; then
      echo "[*] Detected repository changes. Pushing snapshot to HF private dataset..."
      git add -A
      git commit -m "vault: automated sync snapshot $(date -u +'%Y-%m-%d %H:%M:%S UTC')" >/dev/null 2>&1 || true
      git push origin main >/dev/null 2>&1 || true
      echo "[+] Vault sync to HF completed."
    fi
  fi
done
