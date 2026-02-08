# MissionBound Agent — Dockerfile v2.2
# Fix: CMD avec shell pour voir les erreurs

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

# Sécurité
RUN adduser -D appuser && chown -R appuser /app /data
USER appuser

EXPOSE 8080

# CMD avec shell pour capturer les erreurs
CMD openclaw gateway --config ./config.json --port 8080 2>&1 || (echo "Exit code: $?" && sleep 30)
