# MissionBound Agent — Dockerfile v2.0
# Corrigé: skills/ copié, version pinnée, user non-root, VISION.md non requis au build

FROM node:22-alpine

RUN apk add --no-cache git curl

WORKDIR /app

# VERSION PINNÉE (reproductibilité — ajuster selon version OpenClaw stable)
RUN npm install -g openclaw@1.2.0

# Fichiers système core
# Note: VISION.md provient de sync.yml (orkestra-memory), pas du repo local.
# Si absent au démarrage, l'agent fonctionne mais sans ref enterprise.
COPY SOUL.md AGENTS.md TOOLS.md railway.toml ./

# Configuration runtime
COPY config.json ./

# Mémoire agent (fichier initial)
COPY MEMORY.md ./

# CI/CD sync workflows
COPY .github/ ./.github/

# SKILLS — CRITIQUE (manquant dans v1.0)
COPY skills/ ./skills/

# Schemas partagés (créés Phase 3, présents si disponibles)
COPY schemas/ ./schemas/ 2>/dev/null || true

# Security governance (créée Phase 3, présente si disponible)
COPY security/ ./security/ 2>/dev/null || true

# Mémoire persistante (volume Railway requis pour persistence)
RUN mkdir -p /data/.openclaw/agents/missionbound-growth/memory

# Sécurité : user non-root
RUN adduser -D appuser && chown -R appuser /app /data
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["openclaw", "gateway", "--config", "./config.json", "--port", "8080"]
