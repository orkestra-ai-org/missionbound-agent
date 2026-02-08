#!/bin/sh
# OpenClaw Gateway Entrypoint pour Railway - avec setup non-interactif

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

# Création de l'agent via setup non-interactif
if [ ! -d /root/.openclaw/agents/missionbound-growth ]; then
    echo "Creating agent missionbound-growth..."
    mkdir -p /root/.openclaw/agents/missionbound-growth
    
    # Copie des fichiers de personnalité
    cp /app/SOUL.md /root/.openclaw/agents/missionbound-growth/SOUL.md 2>/dev/null || true
    cp /app/AGENTS.md /root/.openclaw/agents/missionbound-growth/AGENTS.md 2>/dev/null || true
    cp /app/TOOLS.md /root/.openclaw/agents/missionbound-growth/TOOLS.md 2>/dev/null || true
    cp /app/MEMORY.md /root/.openclaw/agents/missionbound-growth/MEMORY.md 2>/dev/null || true
    
    # Création du fichier agent.json
    cat > /root/.openclaw/agents/missionbound-growth/agent.json << 'EOF'
{
  "id": "missionbound-growth",
  "name": "MissionBound Growth",
  "version": "2.0.0",
  "soulMdPath": "./SOUL.md",
  "agentsMdPath": "./AGENTS.md",
  "toolsMdPath": "./TOOLS.md",
  "memoryMdPath": "./MEMORY.md"
}
EOF
    echo "Agent created with personality files"
fi

# Config gateway
if [ ! -f /data/.openclaw/openclaw.json ]; then
    cat > /data/.openclaw/openclaw.json << 'EOF'
{
  "gateway": {
    "mode": "local",
    "port": 8080,
    "host": "0.0.0.0",
    "auth": {
      "mode": "token",
      "token": "missionbound-token-2026"
    }
  },
  "agent": {
    "id": "missionbound-growth"
  }
}
EOF
fi

# Démarrage SANS --allow-unconfigured
cd /app
exec openclaw gateway --token missionbound-token-2026
