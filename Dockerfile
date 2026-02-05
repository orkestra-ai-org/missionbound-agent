# MissionBound — Dockerfile

FROM node:22-alpine

RUN apk add --no-cache git curl

WORKDIR /app

RUN npm install -g openclaw@latest

COPY SOUL.md AGENTS.md TOOLS.md VISION.md railway.toml ./
COPY .github/ ./.github/

RUN mkdir -p /data/.openclaw/agents/missionbound-growth

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["openclaw", "gateway", "--port", "8080"]
