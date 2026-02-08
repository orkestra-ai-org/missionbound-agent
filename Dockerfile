# MissionBound Agent — Dockerfile v2.8
# Fix: entrypoint.sh séparé pour éviter les problèmes de quotes

FROM node:22-slim

# Cache-bust pour forcer rebuild propre
ARG CACHE_BUST=1

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    cmake \
    make \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation OpenClaw
RUN npm install -g openclaw

# Fichiers système core
COPY SOUL.md AGENTS.md TOOLS.md railway.toml ./
COPY config.json ./
COPY openclaw.json ./
COPY MEMORY.md ./
COPY .github/ ./.github/
COPY skills/ ./skills/
COPY entrypoint.sh ./
RUN chmod +x /app/entrypoint.sh

# (La config sera créée au runtime par entrypoint.sh)

# Dossiers optionnels
RUN mkdir -p ./schemas ./security
RUN if [ -d schemas ] && [ "$(ls -A schemas 2>/dev/null)" ]; then cp -r schemas/* ./schemas/ 2>/dev/null || true; fi
RUN if [ -d security ] && [ "$(ls -A security 2>/dev/null)" ]; then cp -r security/* ./security/ 2>/dev/null || true; fi

# Mémoire persistante
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory
RUN chmod -R 777 /data

# Variable d'environnement pour le port Railway
ENV PORT=8080
EXPOSE 8080

# Entrypoint
RUN ln -sf /app/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
