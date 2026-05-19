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

# Wait for Ollama (this one is necessary)
echo "Waiting for Ollama..."
until curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; do
  sleep 1
done
echo "Ollama is ready!"

echo "Launching OpenClaw (install + start)..."
ollama launch openclaw --model qwen3.5:latest --yes

# LAUNCH_PID=$!

# # === Smart wait: Poll until openclaw CLI is available ===
# echo "Waiting for OpenClaw installation to complete..."
# for i in $(seq 1 60); do
#   if command -v openclaw >/dev/null 2>&1; then
#     echo "OpenClaw CLI is now available!"
#     break
#   fi
#   sleep 2
# done

# # Extra safety check - wait until config file or gateway command works
# if ! command -v openclaw >/dev/null 2>&1; then
#   echo "ERROR: OpenClaw did not install properly"
#   exit 1
# fi

# echo "Applying configuration..."
# openclaw config set gateway.binding "lan"
# openclaw config set gateway.mode "local"
# openclaw config set gateway.auth.token "gbagabond"
# openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]'

# echo "Current gateway config:"
# openclaw config get gateway

# echo "Stopping current instance cleanly..."
# openclaw gateway stop || true
# sleep 2

# echo "Re-launching OpenClaw with final settings..."
# exec ollama launch openclaw --model qwen3.5:latest --yes