# ==============================================================================
# RMAA GitVault - Sovereign Self-Hosted Git Platform for Render Free Tier
# Multi-stage optimized Alpine container
# ==============================================================================
FROM gitea/gitea:1.22-rootless

USER root

# Install CA certificates and lightweight tools
RUN apk --no-cache add ca-certificates curl wget bash

# Copy custom entrypoint with keep-alive self-ping daemon
COPY entrypoint.sh /usr/local/bin/gitvault-entrypoint.sh
RUN chmod +x /usr/local/bin/gitvault-entrypoint.sh

USER 1000:1000
WORKDIR /var/lib/gitea

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/gitvault-entrypoint.sh"]
