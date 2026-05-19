#!/bin/sh

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Permissions & dirs
mkdir -p /root/.openclaw /root/.ollama
chmod -R 755 /root/.ollama 2>/dev/null || true

# Initialize Ollama directory
if [ ! -d "/root/.ollama/models" ]; then
  echo "Initializing Ollama directory structure..."
  mkdir -p /root/.ollama/models
fi

# Ollama environment
export OLLAMA_MODELS=/root/.ollama/models
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

echo "Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama
echo "Waiting for Ollama to be ready..."
until curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; do
  sleep 1
done
echo "Ollama is ready!"

sleep 2

# Debug info
echo "Ollama directory contents:"
ls -la /root/.ollama/ 2>/dev/null || echo "No .ollama directory"
curl -s http://127.0.0.1:11434/api/tags | head -c 200

echo "Launching OpenClaw via Ollama (this will install it if needed)..."

# Option 1: Let Ollama handle install + basic config, then fine-tune with OpenClaw CLI
ollama launch openclaw --model qwen3.5:latest --yes

# Wait a moment for OpenClaw to be installed and config file to exist
sleep 5

echo "Applying custom gateway settings via OpenClaw CLI..."

# Use OpenClaw's config commands (preferred over direct JSON editing)
openclaw config set gateway.binding "lan" || true
openclaw config set gateway.mode "local" || true
openclaw config set gateway.auth.token "gbagabond" || true

# Control UI origins
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]' --strict-json || true

# Optional: Verify config
echo "Current gateway config:"
openclaw config get gateway

echo "Stopping gateway cleanly..."
openclaw gateway stop || true
sleep 3   # Give it time to fully shut down

echo "Re-launching OpenClaw with your model..."
exec ollama launch openclaw --model qwen3.5:latest --yes