# 🛡️ RMAA GitVault

Sovereign, ultra-reliable, zero-cost self-hosted Git platform built for the **RMAA Holdings** ecosystem.

Designed to operate seamlessly on **Render Free Tier** by completely eliminating local disk storage dependencies and cold-start sleep delays.

🔗 **Live Instance**: [https://pgit-jpw1.onrender.com](https://pgit-jpw1.onrender.com)

---

## 🏛️ Architecture

```
                    ┌────────────────────────────────────────┐
                    │               DEVELOPER                │
                    │  git clone https://pgit-jpw1.onrender  │
                    └───────────────────┬────────────────────┘
                                        │
                                        ▼
                    ┌────────────────────────────────────────┐
                    │        RENDER DOCKER CONTAINER         │
                    │         (512 MB RAM, Port 3000)        │
                    ├────────────────────────────────────────┤
                    │ • GitVault Rootless Daemon             │
                    │ • Self-Ping Keep-Alive (every 13m)     │
                    │ • Stateless Ephemeral Execution        │
                    └───────────────────┬────────────────────┘
                                        │
                 ┌──────────────────────┴──────────────────────┐
                 ▼                                             ▼
     ┌───────────────────────┐                     ┌───────────────────────┐
     │  SUPABASE POSTGRESQL  │                     │   HUGGING FACE S3     │
     │   POOLED DATABASE     │                     │     BUCKET VAULT      │
     │  (Metadata, Users,    │                     │  (Bare Git Objects,   │
     │   PRs, Audit Trail)   │                     │   LFS, Repositories)  │
     └───────────────────────┘                     └───────────────────────┘
```

---

## 🚀 Key Features

- **24/7 Zero Cold-Boot Keep-Alive**: Built-in background daemon issues keep-alive heartbeats to Render every 13 minutes, preventing container sleep on the free plan.
- **Zero Disk Dependence**: All repositories, Git LFS artifacts, attachments, and packages stream directly to a private **Hugging Face S3-compatible Bucket** (`rmaapk/pgit`).
- **High-Availability PostgreSQL**: Backed by **Supabase Pooled PostgreSQL** (`aws-0-ap-northeast-2.pooler.supabase.com:6543`), ensuring instant transactions and zero data loss across container teardowns.
- **Instance URL**: Live endpoint at [`https://pgit-jpw1.onrender.com`](https://pgit-jpw1.onrender.com).
- **Secret Separation**: Strictly reads configuration from environment variables / `.env` for safe deployment in public repositories.

---

## ⚙️ Environment Variables

Copy `.env.example` to `.env` or set these in the **Render Dashboard -> Environment**:

| Variable | Description | Example / Target |
| :--- | :--- | :--- |
| `GITEA__server__DOMAIN` | Public domain | `pgit-jpw1.onrender.com` |
| `GITEA__server__ROOT_URL` | Public base URL | `https://pgit-jpw1.onrender.com/` |
| `GITEA__database__HOST` | Supabase Postgres host and port | `aws-0-ap-northeast-2.pooler.supabase.com:6543` |
| `GITEA__database__NAME` | Postgres database name | `postgres` |
| `GITEA__database__USER` | Supabase pooled username | `postgres.sjjcilrjqavsgnqjjjlz` |
| `GITEA__database__PASSWD` | Supabase database password | *(Secret)* |
| `GITEA__storage__STORAGE_TYPE` | Storage engine | `minio` (S3 compatible) |
| `GITEA__storage__MINIO_ENDPOINT` | HF S3 Endpoint | `s3.huggingface.co` |
| `GITEA__storage__MINIO_ACCESS_KEY_ID` | HF account / organization | `rmaapk` |
| `GITEA__storage__MINIO_SECRET_ACCESS_KEY` | Hugging Face Access Token | *(Secret)* |
| `GITEA__storage__MINIO_BUCKET` | HF S3 Bucket path | `rmaapk/pgit` |
| `KEEP_ALIVE_URL` | Keepalive target | `https://pgit-jpw1.onrender.com/api/v1/version` |

---

## 📜 License

BSL 1.1 — Sovereign RMAA Holdings Ecosystem.
