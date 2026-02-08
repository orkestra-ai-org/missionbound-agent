# MissionBound Agent — Dockerfile v2.3
# Fix: Debugging complet + initialisation

FROM node:22-alpine

RUN apk add --no-cache git curl

WORKDIR /app

# VERSION PINNÉE
RUN npm install -g openclaw@1.2.0

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

# Permissions (root pour le moment)
RUN chmod -R 777 /data

EXPOSE 8080

# Script d'entrypoint pour debugging
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -x' >> /entrypoint.sh && \
    echo 'echo "=== Starting MissionBound Agent ==="' >> /entrypoint.sh && \
    echo 'echo "Current dir: $(pwd)"' >> /entrypoint.sh && \
    echo 'echo "Files: $(ls -la)"' >> /entrypoint.sh && \
    echo 'echo "OpenClaw version: $(openclaw --version)"' >> /entrypoint.sh && \
    echo 'echo "Config content:" && cat ./config.json' >> /entrypoint.sh && \
    echo 'echo "=== Starting Gateway ==="' >> /entrypoint.sh && \
    echo 'exec openclaw gateway --config ./config.json --port 8080' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
