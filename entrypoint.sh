#!/bin/sh
# OpenClaw Gateway Entrypoint pour Railway

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Dossiers
mkdir -p /root/.openclaw/agents/main/agent
mkdir -p /data/.openclaw

# Création de la config minimale
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
  }
}
EOF
    echo "Created openclaw.json"
fi

# Auth profiles
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
    echo "Auth profiles configured"
fi

# IMPORTANT: Configurer l'agent dans le dossier agents/
mkdir -p /root/.openclaw/agents/missionbound-growth
if [ ! -f /root/.openclaw/agents/missionbound-growth/agent.json ]; then
    cat > /root/.openclaw/agents/missionbound-growth/agent.json << 'EOF'
{
  "id": "missionbound-growth",
  "name": "MissionBound Growth",
  "soulMdPath": "/app/SOUL.md",
  "agentsMdPath": "/app/AGENTS.md",
  "toolsMdPath": "/app/TOOLS.md",
  "memoryMdPath": "/app/MEMORY.md"
}
EOF
    echo "Created agent.json"
fi

# Vérification
echo "=== Fichiers config ==="
ls -la /data/.openclaw/
ls -la /root/.openclaw/agents/

# Démarrage avec --allow-unconfigured mais avec la config copiée
cd /app
exec openclaw gateway --token missionbound-token-2026 --allow-unconfigured
