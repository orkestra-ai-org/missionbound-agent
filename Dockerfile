# MissionBound Agent — Dockerfile v2.1
# Corrigé: syntaxe COPY invalide avec redirection shell

FROM node:22-alpine

RUN apk add --no-cache git curl

WORKDIR /app

# VERSION PINNÉE (reproductibilité — ajuster selon version OpenClaw stable)
RUN npm install -g openclaw@1.2.0

# Fichiers système core
COPY SOUL.md AGENTS.md TOOLS.md railway.toml ./

# Configuration runtime
COPY config.json ./

# Mémoire agent (fichier initial)
COPY MEMORY.md ./

# CI/CD sync workflows
COPY .github/ ./.github/

# SKILLS — CRITIQUE (manquant dans v1.0)
COPY skills/ ./skills/

# Création des dossiers optionnels (évite l'erreur COPY avec redirection)
RUN mkdir -p ./schemas ./security

# Copie optionnelle des dossiers (gérée via shell, ignore si absents)
RUN if [ -d schemas ] && [ "$(ls -A schemas 2>/dev/null)" ]; then cp -r schemas/* ./schemas/ 2>/dev/null || true; fi
RUN if [ -d security ] && [ "$(ls -A security 2>/dev/null)" ]; then cp -r security/* ./security/ 2>/dev/null || true; fi

# Mémoire persistante (volume Railway requis pour persistence)
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory

# Sécurité : user non-root
RUN adduser -D appuser && chown -R appuser /app /data
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["openclaw", "gateway", "--config", "./config.json", "--port", "8080"]
