#!/bin/sh
set -e

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Permissions & dirs
mkdir -p /root/.openclaw /root/.ollama
chown -R 1000:1000 /root 2>/dev/null || true
chmod -R 755 /root

echo "Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to be ready..."
until curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; do
  sleep 1
done
echo "Ollama is ready!"

echo "Configuring OpenClaw..."

# Base gateway config
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]'
openclaw config set gateway.mode local
openclaw config set gateway.auth.token gbagabond

# Ollama provider (OpenAI-compatible endpoint)
openclaw config set models.providers.ollama.baseUrl 'http://127.0.0.1:11434/v1'
openclaw config set models.providers.ollama.apiKey 'ollama-local'
openclaw config set models.providers.ollama.api 'openai-completions'
openclaw config set models.providers.ollama.models '["qwen3:72b"]'

echo "Pulling/ensuring powerful model (this may take time on first deploy)..."

# Pull the model (will be cached in volume)
ollama pull qwen3:72b

# Set as primary/default model for all agents
openclaw models set ollama/qwen3:72b

echo "✅ Powerful local model (qwen3:72b) set as default!"
echo "Starting Gateway..."

exec openclaw gateway