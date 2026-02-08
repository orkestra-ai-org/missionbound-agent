#!/bin/sh
# OpenClaw Gateway Entrypoint - Fix v2 par Claude Code
# Corrections: mode hosted, channels.telegram, TELEGRAM_OWNER_ID

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Configuration OpenClaw
export OPENCLAW_STATE_DIR=/data/.openclaw
mkdir -p $OPENCLAW_STATE_DIR

# Génération dynamique de openclaw.json avec les bonnes valeurs
if [ ! -f $OPENCLAW_STATE_DIR/openclaw.json ]; then
    # Construction de la config Telegram si TELEGRAM_OWNER_ID est set
    TELEGRAM_BLOCK=""
    if [ -n "$TELEGRAM_OWNER_ID" ]; then
        TELEGRAM_BLOCK='
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowlist": ['"$TELEGRAM_OWNER_ID"']
    }
  },'
    fi

    cat > $OPENCLAW_STATE_DIR/openclaw.json << EOF
{
  "gateway": {
    "mode": "hosted",
    "port": 8080,
    "auth": {
      "mode": "token",
      "token": "missionbound-token-2026"
    }
  },${TELEGRAM_BLOCK}
  "agents": {
    "defaults": {
      "workspace": "/app"
    }
  }
}
EOF
    echo "Created openclaw.json with mode=hosted"
fi

# Auth profiles
mkdir -p /root/.openclaw/agents/main/agent
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
    echo "Auth profiles configured"
fi

# Vérification
echo "=== Config ==="
cat $OPENCLAW_STATE_DIR/openclaw.json

# Démarrage
cd /app
exec openclaw gateway --token missionbound-token-2026
