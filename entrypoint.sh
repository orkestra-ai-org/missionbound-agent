#!/bin/sh
# OpenClaw Gateway Entrypoint - Mode "personnalité forcée"

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Dossiers
mkdir -p /root/.openclaw/agents/main/agent
mkdir -p /data/.openclaw

# Auth profiles
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
    echo "Auth profiles configured"
fi

# HACK: Copie les fichiers de personnalité directement dans le dossier "main" agent
# Quand --allow-unconfigured est utilisé, OpenClaw utilise l'agent "main"
mkdir -p /root/.openclaw/agents/main/agent
cp /app/SOUL.md /root/.openclaw/agents/main/agent/SOUL.md 2>/dev/null || true
cp /app/AGENTS.md /root/.openclaw/agents/main/agent/AGENTS.md 2>/dev/null || true
cp /app/TOOLS.md /root/.openclaw/agents/main/agent/TOOLS.md 2>/dev/null || true
cp /app/MEMORY.md /root/.openclaw/agents/main/agent/MEMORY.md 2>/dev/null || true

# Création d'un agent.json pour l'agent "main" (utilisé par --allow-unconfigured)
cat > /root/.openclaw/agents/main/agent.json << 'EOFMAIN'
{
  "id": "main",
  "name": "MissionBound Growth",
  "soulMdPath": "./agent/SOUL.md",
  "agentsMdPath": "./agent/AGENTS.md",
  "toolsMdPath": "./agent/TOOLS.md",
  "memoryMdPath": "./agent/MEMORY.md"
}
EOFMAIN

echo "=== Fichiers copiés dans main/agent ==="
ls -la /root/.openclaw/agents/main/agent/

# Démarrage avec --allow-unconfigured MAIS avec les fichiers en place
cd /app
exec openclaw gateway --token missionbound-token-2026 --allow-unconfigured
