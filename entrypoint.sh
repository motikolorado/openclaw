#!/bin/sh

echo "=== OpenClaw + Powerful Local Ollama on GPU ==="

# Permissions & dirs
mkdir -p /root/.openclaw /root/.ollama

# Ensure proper ownership for Ollama (runs as root in container)
# Ollama needs write access to /root/.ollama
chmod -R 755 /root/.ollama 2>/dev/null || true

# Initialize Ollama directory structure if needed
# This ensures the models directory exists
if [ ! -d "/root/.ollama/models" ]; then
  echo "Initializing Ollama directory structure..."
  mkdir -p /root/.ollama/models
fi

# Set Ollama environment to use the correct directory
export OLLAMA_MODELS=/root/.ollama/models
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS="*"

echo "Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to be ready..."
until curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; do
  sleep 1
done
echo "Ollama is ready!"

# Debug: Show Ollama status
echo "Ollama directory contents:"
ls -la /root/.ollama/ 2>/dev/null || echo "No .ollama directory"

echo "Configuring OpenClaw..."

# Remove old config to ensure clean state
rm -f /root/.openclaw/openclaw.json

# Create the config file directly with proper structure
# This ensures the models array is properly formatted
cat > /root/.openclaw/openclaw.json << 'EOF'
{
  "gateway": {
    "controlUi": {
      "allowedOrigins": ["https://koloclaw.fly.dev"]
    },
    "mode": "local",
    "auth": {
      "token": "gbagabond"
    }
  },
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": ["qwen3:72b"]
      }
    }
  }
}
EOF

echo "Pulling/ensuring powerful model (this may take time on first deploy)..."

# Check if model already exists
if ollama list 2>/dev/null | grep -q "qwen3:72b"; then
  echo "Model qwen3:72b already downloaded, skipping pull..."
else
  # Pull the model (will be cached in volume)
  echo "Pulling qwen3:72b model..."
  ollama pull qwen3:72b || echo "Warning: Model pull failed, will retry on next startup"
fi

# Set as primary/default model for all agents
openclaw models set ollama/qwen3:72b

echo "✅ Powerful local model (qwen3:72b) set as default!"
echo "Starting Gateway..."

exec openclaw gateway