#!/bin/sh
set -e

echo "=== [RMAA GitVault Engine Initializing] ==="

# Render runs rootless container; ensure app.ini path exists with install lock
mkdir -p /etc/gitea /data/gitea/conf

cat << INI_EOF > /etc/gitea/app.ini
APP_NAME = RMAA GitVault
RUN_USER = git
WORK_PATH = /var/lib/gitea
RUN_MODE = prod

[server]
DOMAIN = ${GITEA__server__DOMAIN:-pgit-jpw1.onrender.com}
ROOT_URL = ${GITEA__server__ROOT_URL:-https://pgit-jpw1.onrender.com/}
HTTP_PORT = ${PORT:-3000}
DISABLE_SSH = true
OFFLINE_MODE = false

[database]
DB_TYPE = ${GITEA__database__DB_TYPE:-postgres}
HOST = ${GITEA__database__HOST}
NAME = ${GITEA__database__NAME:-postgres}
USER = ${GITEA__database__USER}
PASSWD = ${GITEA__database__PASSWD}
SSL_MODE = ${GITEA__database__SSL_MODE:-require}
LOG_SQL = false

[storage]
STORAGE_TYPE = ${GITEA__storage__STORAGE_TYPE:-minio}
MINIO_ENDPOINT = ${GITEA__storage__MINIO_ENDPOINT:-s3.huggingface.co}
MINIO_ACCESS_KEY_ID = ${GITEA__storage__MINIO_ACCESS_KEY_ID}
MINIO_SECRET_ACCESS_KEY = ${GITEA__storage__MINIO_SECRET_ACCESS_KEY}
MINIO_BUCKET = ${GITEA__storage__MINIO_BUCKET:-rmaapk/pgit}
MINIO_LOCATION = ${GITEA__storage__MINIO_LOCATION:-us-east-1}
MINIO_USE_SSL = true

[lfs]
STORAGE_TYPE = minio

[attachment]
STORAGE_TYPE = minio

[packages]
STORAGE_TYPE = minio

[security]
INSTALL_LOCK = true
SECRET_KEY = ${GITEA__security__SECRET_KEY:-c3697ebf071488c9cfaf0d3b64c23dbfae6df29c719e78a63588f98c772cb23f}

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false

[session]
PROVIDER = memory
INI_EOF

echo "[+] Generated /etc/gitea/app.ini with INSTALL_LOCK=true"

# Background Keep-Alive Self-Ping Daemon (Bypasses Render 15-minute sleep)
(
  echo "[+] GitVault Keep-Alive Daemon started."
  while true; do
    sleep 780
    TARGET="${KEEP_ALIVE_URL:-http://127.0.0.1:3000/api/v1/version}"
    echo "[*] Keep-Alive Ping -> ${TARGET}"
    wget -qO- --timeout=15 "${TARGET}" > /dev/null 2>&1 || true
  done
) &

# Launch Gitea directly with generated config to bypass installation wizard
exec /usr/local/bin/gitea -c /etc/gitea/app.ini web
