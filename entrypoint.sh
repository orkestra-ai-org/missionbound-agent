#!/bin/sh
# OpenClaw Gateway Entrypoint - Schema validé

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Configuration OpenClaw
export OPENCLAW_STATE_DIR=/data/.openclaw
mkdir -p $OPENCLAW_STATE_DIR

# Config MINIMALE valide (pas de hosted, pas de allowlist)
if [ ! -f $OPENCLAW_STATE_DIR/openclaw.json ]; then
    cat > $OPENCLAW_STATE_DIR/openclaw.json << 'EOF'
{
  "gateway": {
    "mode": "local",
    "port": 8080,
    "auth": {
      "mode": "token",
      "token": "missionbound-token-2026"
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/app"
    }
  }
}
EOF
    echo "Created minimal config"
fi

# Auth profiles
mkdir -p /root/.openclaw/agents/main/agent
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
    echo "Auth profiles configured"
fi

# Démarrage avec --allow-unconfigured (mode qui fonctionne)
cd /app
exec openclaw gateway --token missionbound-token-2026 --allow-unconfigured
