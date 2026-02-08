#!/bin/sh
# OpenClaw Gateway Entrypoint - Config correcte selon schema OpenClaw

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Configuration OpenClaw
export OPENCLAW_STATE_DIR=/data/.openclaw
mkdir -p $OPENCLAW_STATE_DIR

# Copie de la config au bon endroit (OPENCLAW_STATE_DIR/openclaw.json)
if [ -f /app/openclaw.json ]; then
    cp /app/openclaw.json $OPENCLAW_STATE_DIR/openclaw.json
    echo "Config copied to $OPENCLAW_STATE_DIR/openclaw.json"
fi

# Auth profiles
mkdir -p /root/.openclaw/agents/main/agent
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
    echo "Auth profiles configured"
fi

# Vérification
ls -la $OPENCLAW_STATE_DIR/
cat $OPENCLAW_STATE_DIR/openclaw.json

# Démarrage SANS --allow-unconfigured (la config est maintenant correcte)
cd /app
exec openclaw gateway --token missionbound-token-2026
