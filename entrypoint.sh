#!/bin/sh
set -e

echo "=== [RMAA GitVault Engine Initializing] ==="

mkdir -p /etc/gitea /data/gitea/conf /var/lib/gitea/data /var/lib/gitea/git

PORT="${PORT:-3000}"

cat << INI_EOF > /etc/gitea/app.ini
APP_NAME = RMAA GitVault
RUN_USER = git
WORK_PATH = /var/lib/gitea
RUN_MODE = prod

[server]
DOMAIN = ${GITEA__server__DOMAIN:-pgit-jpw1.onrender.com}
ROOT_URL = ${GITEA__server__ROOT_URL:-https://pgit-jpw1.onrender.com/}
HTTP_ADDR = 0.0.0.0
HTTP_PORT = ${PORT}
DISABLE_SSH = true
OFFLINE_MODE = true
ENABLE_GZIP = true

[database]
DB_TYPE = postgres
HOST = ${GITEA__database__HOST:-aws-0-ap-northeast-2.pooler.supabase.com:5432}
NAME = ${GITEA__database__NAME:-postgres}
USER = ${GITEA__database__USER:-postgres.sjjcilrjqavsgnqjjjlz}
PASSWD = ${GITEA__database__PASSWD}
SSL_MODE = require
LOG_SQL = false
MAX_OPEN_CONNS = 30
MAX_IDLE_CONNS = 15
CONN_MAX_LIFETIME = 300s

[cache]
ADAPTER = memory
INTERVAL = 60

[repository]
ROOT = /var/lib/gitea/git/repositories
DEFAULT_BRANCH = main

[repository.pull-request]
WORK_IN_PROGRESS_PREFIXES = WIP:,[WIP]

[storage]
STORAGE_TYPE = local
PATH = /var/lib/gitea/data

[security]
INSTALL_LOCK = true
SECRET_KEY = ${GITEA__security__SECRET_KEY:-c3697ebf071488c9cfaf0d3b64c23dbfae6df29c719e78a63588f98c772cb23f}

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false

[session]
PROVIDER = memory

[cron.repo_health_check]
SCHEDULE = @midnight
INI_EOF

echo "[+] Generated /etc/gitea/app.ini with connection pool & in-memory cache"

# 1. Background Keep-Alive Self-Ping Daemon (Pings every 13 minutes)
(
  echo "[+] GitVault Keep-Alive Daemon started."
  while true; do
    sleep 780
    TARGET="${KEEP_ALIVE_URL:-http://127.0.0.1:${PORT}/api/v1/version}"
    echo "[*] Keep-Alive Ping -> ${TARGET}"
    wget -qO- --timeout=15 "${TARGET}" > /dev/null 2>&1 || true
  done
) &

# 2. Launch Background Git-Xet / Hugging Face Private Dataset Sync Daemon
if [ -x /usr/local/bin/gitvault-sync.sh ]; then
  /usr/local/bin/gitvault-sync.sh &
fi

# 3. Launch Gitea Web Server directly
exec /usr/local/bin/gitea -c /etc/gitea/app.ini web
