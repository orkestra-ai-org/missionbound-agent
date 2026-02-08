#!/bin/sh
# OpenClaw Gateway Entrypoint - Avec proxy pour exposer sur 0.0.0.0

# Nettoyage
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -f "openclaw gateway" 2>/dev/null || true
sleep 1

# Configuration OpenClaw
export OPENCLAW_STATE_DIR=/data/.openclaw
mkdir -p $OPENCLAW_STATE_DIR

# Config minimale
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
fi

# Auth profiles
mkdir -p /root/.openclaw/agents/main/agent
if [ -n "$OPENROUTER_API_KEY" ]; then
    printf '{\n  "anthropic": {\n    "apiKey": "%s",\n    "baseURL": "https://openrouter.ai/api/v1"\n  },\n  "openrouter": {\n    "apiKey": "%s"\n  }\n}\n' "$OPENROUTER_API_KEY" "$OPENROUTER_API_KEY" > /root/.openclaw/agents/main/agent/auth-profiles.json
fi

# Démarre OpenClaw en arrière-plan sur le port 8081 (interne)
cd /app
openclaw gateway --token missionbound-token-2026 --allow-unconfigured &
OPENCLAW_PID=$!

# Attends qu'il démarre
sleep 5

# Démarre un proxy TCP simple qui écoute sur 0.0.0.0:8080 et forward vers 127.0.0.1:8080
# Utilise socat ou nc
if command -v socat >/dev/null 2>&1; then
    socat TCP-LISTEN:8080,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:8080 &
elif command -v nc >/dev/null 2>&1; then
    # Alternative avec nc si disponible
    while true; do nc -l -p 8080 -c 'nc 127.0.0.1 8080' 2>/dev/null; done &
else
    echo "WARNING: ni socat ni nc disponible pour le proxy"
fi

# Attends que OpenClaw se termine
wait $OPENCLAW_PID
