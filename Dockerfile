# MissionBound Agent — Dockerfile v2.4
# Fix: OpenClaw version inexistante (1.2.0 n'existe pas sur npm)

FROM node:22-alpine

RUN apk add --no-cache git curl

WORKDIR /app

# Installation OpenClaw (dernière version disponible)
RUN npm install -g openclaw

# Fichiers système core
COPY SOUL.md AGENTS.md TOOLS.md railway.toml ./
COPY config.json ./
COPY MEMORY.md ./
COPY .github/ ./.github/
COPY skills/ ./skills/

# Dossiers optionnels
RUN mkdir -p ./schemas ./security
RUN if [ -d schemas ] && [ "$(ls -A schemas 2>/dev/null)" ]; then cp -r schemas/* ./schemas/ 2>/dev/null || true; fi
RUN if [ -d security ] && [ "$(ls -A security 2>/dev/null)" ]; then cp -r security/* ./security/ 2>/dev/null || true; fi

# Mémoire persistante
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory

# Permissions
RUN chmod -R 777 /data

EXPOSE 8080

# Script d'entrypoint avec debugging
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -x' >> /entrypoint.sh && \
    echo 'echo "=== Starting MissionBound Agent ==="' >> /entrypoint.sh && \
    echo 'echo "OpenClaw version: $(openclaw --version 2>&1 || echo \"version check failed\")"' >> /entrypoint.sh && \
    echo 'echo "=== Starting Gateway ==="' >> /entrypoint.sh && \
    echo 'exec openclaw gateway --config ./config.json --port 8080' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
