#!/bin/sh
set -e

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Permissions & dirs
mkdir -p /root/.openclaw /root/.ollama
chown -R 1000:1000 /root 2>/dev/null || true
chmod -R 755 /root

echo "Configuring OpenClaw..."

# Base gateway config
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]'
openclaw config set gateway.mode local
openclaw config set gateway.auth.token gbagabond

# Ollama provider (OpenAI-compatible endpoint)
openclaw config set models.providers.ollama.baseUrl 'http://127.0.0.1:11434/v1'
openclaw config set models.providers.ollama.apiKey 'ollama-local'
openclaw config set models.providers.ollama.api 'openai-completions'

echo "Pulling/ensuring powerful model (this may take time on first deploy)..."

# Best powerful models (pick one that fits ~48-60GB VRAM on L40s with good quant)
# Recommended order:
# 1. Qwen3-72B or Llama-4-70B variants (strongest reasoning)
ollama pull qwen3:72b   # or llama4:70b, gemma3:70b etc. — adjust based on testing

# Set as primary/default model for all agents
openclaw models set ollama/qwen3:72b

echo "✅ Powerful local model (qwen3:72b) set as default!"
echo "Starting Gateway..."

exec openclaw gateway
