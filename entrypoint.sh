#!/bin/sh
# OpenClaw Gateway Entrypoint - Setup propre de l'agent

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

# Création de l'agent via la CLI OpenClaw (si pas déjà existant)
if [ ! -f /root/.openclaw/agents/missionbound-growth/agent.json ]; then
    echo "Creating agent via openclaw CLI..."
    
    # Création du dossier agent
    mkdir -p /root/.openclaw/agents/missionbound-growth
    
    # Copie des fichiers
    cp /app/SOUL.md /root/.openclaw/agents/missionbound-growth/
    cp /app/AGENTS.md /root/.openclaw/agents/missionbound-growth/
    cp /app/TOOLS.md /root/.openclaw/agents/missionbound-growth/
    cp /app/MEMORY.md /root/.openclaw/agents/missionbound-growth/
    
    # Création du agent.json
    cat > /root/.openclaw/agents/missionbound-growth/agent.json << 'EOF'
{
  "id": "missionbound-growth",
  "name": "MissionBound Growth",
  "version": "2.0.0",
  "soulMdPath": "./SOUL.md",
  "agentsMdPath": "./AGENTS.md",
  "toolsMdPath": "./TOOLS.md",
  "memoryMdPath": "./MEMORY.md",
  "capabilities": ["memory", "tools", "sessions"]
}
EOF
    
    # Marquer comme agent actif
    echo "missionbound-growth" > /root/.openclaw/agents/.active
    
    echo "Agent missionbound-growth created"
fi

# Config gateway avec référence à l'agent
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
  "activeAgent": "missionbound-growth"
}
EOF

echo "=== Structure agents ==="
find /root/.openclaw/agents -type f -name "*.json" -o -name "*.md" | head -20

# Démarrage SANS --allow-unconfigured
echo "Starting gateway..."
cd /app
exec openclaw gateway --token missionbound-token-2026
