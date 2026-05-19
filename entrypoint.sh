#!/bin/sh

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Directories & permissions
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

# 1. Launch with Ollama (install + configure model)
echo "Installing/configuring OpenClaw and setting default model..."
ollama launch openclaw --model qwen3.5:latest --yes

# 2. Wait for CLI to be available
echo "Waiting for OpenClaw CLI..."
for i in $(seq 1 40); do
  if command -v openclaw >/dev/null 2>&1; then
    echo "OpenClaw CLI is ready!"
    break
  fi
  sleep 1.5
done

# 3. Apply your custom config
echo "Applying gateway configuration..."
openclaw config set gateway.binding "lan" || true
openclaw config set gateway.mode "local" || true
openclaw config set gateway.auth.token "gbagabond" || true
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]' || true

echo "Current default model:"
openclaw config get agents.defaults.model.primary || echo "Not set"

# 4. Restart gateway with your desired port + bind
echo "Restarting gateway on port 18789 bound to LAN..."
exec openclaw gateway restart --port 18789 --bind lan