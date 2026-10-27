# ==============================================================================
# RMAA GitVault - Sovereign Self-Hosted Git Platform for Render Free Tier
# Multi-stage optimized Alpine container with Git-Xet / HF Dataset Sync
# ==============================================================================
FROM gitea/gitea:1.22-rootless

USER root

# Install CA certificates, git-lfs, rsync and tools
RUN apk --no-cache add ca-certificates curl wget bash git-lfs rsync openssh-client

# Configure directories with proper ownership for user 1000
RUN mkdir -p /etc/gitea /data/gitea /var/lib/gitea/git /tmp/hf_pgit_sync && \
    chown -R 1000:1000 /etc/gitea /data/gitea /var/lib/gitea /tmp/hf_pgit_sync

# Copy entrypoint and sync scripts
COPY entrypoint.sh /usr/local/bin/gitvault-entrypoint.sh
COPY sync_daemon.sh /usr/local/bin/gitvault-sync.sh
RUN chmod +x /usr/local/bin/gitvault-entrypoint.sh /usr/local/bin/gitvault-sync.sh

USER 1000:1000
WORKDIR /var/lib/gitea

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/gitvault-entrypoint.sh"]
