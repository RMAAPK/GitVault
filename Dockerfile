# ==============================================================================
# RMAA GitVault - Sovereign Self-Hosted Git Platform for Render Free Tier
# Multi-stage optimized Alpine container
# ==============================================================================
FROM gitea/gitea:1.22-rootless

USER root

# Install CA certificates and lightweight tools
RUN apk --no-cache add ca-certificates curl wget bash

# Ensure config directories have correct permissions for user 1000
RUN mkdir -p /etc/gitea /data/gitea && chown -R 1000:1000 /etc/gitea /data/gitea

# Copy custom entrypoint with dynamic env config generation and keepalive
COPY entrypoint.sh /usr/local/bin/gitvault-entrypoint.sh
RUN chmod +x /usr/local/bin/gitvault-entrypoint.sh

USER 1000:1000
WORKDIR /var/lib/gitea

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/gitvault-entrypoint.sh"]
