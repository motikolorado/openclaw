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

echo "Starting openclaw gateway..."
ollama launch openclaw --model qwen3.5:latest --yes
# exec openclaw gateway --port 18789 --bind lan