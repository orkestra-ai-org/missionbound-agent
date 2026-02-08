#!/bin/sh
# OpenClaw Gateway Entrypoint - Proxy 0.0.0.0

# Nettoyage agressif
rm -f /data/.openclaw/gateway.pid /data/.openclaw/*.lock 2>/dev/null || true
pkill -9 -f "openclaw gateway" 2>/dev/null || true
pkill -9 -f "socat" 2>/dev/null || true
sleep 2

# Configuration OpenClaw
export OPENCLAW_STATE_DIR=/data/.openclaw
mkdir -p $OPENCLAW_STATE_DIR

# Config minimale
if [ ! -f $OPENCLAW_STATE_DIR/openclaw.json ]; then
    cat > $OPENCLAW_STATE_DIR/openclaw.json << 'EOF'
{
  "gateway": {
    "mode": "local",
    "port": 8081,
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
PORT=8081 openclaw gateway --token missionbound-token-2026 --allow-unconfigured &
OPENCLAW_PID=$!

# Attends qu'il démarre
sleep 5

# Vérifie qu'il tourne
if ! kill -0 $OPENCLAW_PID 2>/dev/null; then
    echo "ERROR: OpenClaw failed to start"
    exit 1
fi

echo "OpenClaw started on PID $OPENCLAW_PID, starting proxy..."

# Démarre socat pour exposer sur 0.0.0.0:8080
socat TCP-LISTEN:8080,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:8081 &
SOCAT_PID=$!

echo "Proxy started on PID $SOCAT_PID"
echo "Gateway accessible on 0.0.0.0:8080 -> 127.0.0.1:8081"

# Attends que OpenClaw se termine (socat meurt avec)
wait $OPENCLAW_PID
