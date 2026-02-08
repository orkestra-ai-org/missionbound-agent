# MissionBound Agent — Dockerfile v2.7
# Fix: Healthcheck Railway simplifié

FROM node:22-slim

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
COPY MEMORY.md ./
COPY .github/ ./.github/
COPY skills/ ./skills/

# Dossiers optionnels
RUN mkdir -p ./schemas ./security
RUN if [ -d schemas ] && [ "$(ls -A schemas 2>/dev/null)" ]; then cp -r schemas/* ./schemas/ 2>/dev/null || true; fi
RUN if [ -d security ] && [ "$(ls -A security 2>/dev/null)" ]; then cp -r security/* ./security/ 2>/dev/null || true; fi

# Mémoire persistante
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory

# Script d'entrypoint qui configure l'auth au démarrage
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Nettoyage des anciens verrous et process' >> /entrypoint.sh && \
    echo 'rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true' >> /entrypoint.sh && \
    echo 'pkill -f "openclaw gateway" 2>/dev/null || true' >> /entrypoint.sh && \
    echo 'sleep 1' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'mkdir -p /root/.openclaw/agents/main/agent' >> /entrypoint.sh && \
    echo 'if [ -n "$OPENROUTER_API_KEY" ]; then' >> /entrypoint.sh && \
    echo '  cat > /root/.openclaw/agents/main/agent/auth-profiles.json << EOF' >> /entrypoint.sh && \
    echo '{' >> /entrypoint.sh && \
    echo '  "anthropic": {' >> /entrypoint.sh && \
    echo '    "apiKey": "'"'$OPENROUTER_API_KEY'"'",' >> /entrypoint.sh && \
    echo '    "baseURL": "https://openrouter.ai/api/v1"' >> /entrypoint.sh && \
    echo '  },' >> /entrypoint.sh && \
    echo '  "openrouter": {' >> /entrypoint.sh && \
    echo '    "apiKey": "'"'$OPENROUTER_API_KEY'"'"' >> /entrypoint.sh && \
    echo '  }' >> /entrypoint.sh && \
    echo '}' >> /entrypoint.sh && \
    echo 'EOF' >> /entrypoint.sh && \
    echo '  echo "Auth profiles configured"' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'cd /app && exec openclaw gateway --token missionbound-token-2026 --foreground' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Permissions
RUN chmod -R 777 /data

# Variable d'environnement pour le port Railway
ENV PORT=8080
EXPOSE 8080

# Entrypoint
CMD ["/entrypoint.sh"]
