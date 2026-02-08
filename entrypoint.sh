#!/bin/sh
# OpenClaw Gateway Entrypoint - Debug complet

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

# Copie des fichiers de personnalité
cp /app/SOUL.md /root/.openclaw/agents/main/agent/
cp /app/AGENTS.md /root/.openclaw/agents/main/agent/
cp /app/TOOLS.md /root/.openclaw/agents/main/agent/
cp /app/MEMORY.md /root/.openclaw/agents/main/agent/

# Permissions
chmod -R 644 /root/.openclaw/agents/main/agent/*.md

# Création agent.json pour "main"
cat > /root/.openclaw/agents/main/agent.json << 'EOF'
{
  "id": "main",
  "name": "MissionBound Growth",
  "soulMdPath": "./agent/SOUL.md",
  "agentsMdPath": "./agent/AGENTS.md",
  "toolsMdPath": "./agent/TOOLS.md",
  "memoryMdPath": "./agent/MEMORY.md",
  "capabilities": ["memory", "tools", "sessions"]
}
EOF

echo "=== DEBUG: Contenu de /root/.openclaw/agents/main/ ==="
ls -la /root/.openclaw/agents/main/

echo "=== DEBUG: Contenu de /root/.openclaw/agents/main/agent/ ==="
ls -la /root/.openclaw/agents/main/agent/

echo "=== DEBUG: Premieres lignes SOUL.md ==="
head -10 /root/.openclaw/agents/main/agent/SOUL.md 2>/dev/null || echo "SOUL.md non trouve"

echo "=== DEBUG: agent.json ==="
cat /root/.openclaw/agents/main/agent.json

# Démarrage
cd /app
exec openclaw gateway --token missionbound-token-2026 --allow-unconfigured
