#!/bin/sh

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Setup directories
mkdir -p /root/.openclaw /root/.ollama
chmod -R 755 /root/.ollama 2>/dev/null || true

if [ ! -d "/root/.ollama/models" ]; then
  mkdir -p /root/.ollama/models
fi

export OLLAMA_MODELS=/root/.ollama/models
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

echo "Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama
echo "Waiting for Ollama..."
until curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; do
  sleep 1
done
echo "Ollama is ready!"

# === Configure OpenClaw + set default model WITHOUT starting gateway ===
echo "Configuring OpenClaw and setting qwen3.5 as default model..."
ollama launch openclaw --model qwen3.5:latest --config --yes

# Wait for OpenClaw CLI to be ready (smart polling)
echo "Waiting for OpenClaw CLI..."
for i in $(seq 1 40); do
  if command -v openclaw >/dev/null 2>&1; then
    echo "OpenClaw CLI ready!"
    break
  fi
  sleep 1.5
done

# Extra safety: apply config via CLI (in case --config didn't fully set it)
echo "Applying additional gateway settings..."
openclaw config set gateway.binding "lan" || true
openclaw config set gateway.mode "local" || true
openclaw config set gateway.auth.token "gbagabond" || true
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]' || true

echo "Current default model:"
openclaw config get agents.defaults.model.primary || echo "Not set"

echo "Starting OpenClaw Gateway manually..."
exec openclaw gateway --port 18789 --bind lan