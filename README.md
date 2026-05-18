# OpenClaw + Ollama on Fly.io

This setup runs OpenClaw gateway with Ollama (qwen3:72b model) on Fly.io.

## Setup

### 1. Create Persistent Volume

```bash
# Create a single volume for both OpenClaw config and Ollama models
# Shared CPU instances only support 1 volume
fly volumes create openclaw_data --size 100 --region ams
```

> **Note**: The volume needs ~100GB for qwen3:72b model. Adjust size based on your model choice.

### 2. Deploy

```bash
fly deploy
```

### 3. First Deploy

The first deploy will download the qwen3:72b model (~40-50GB). This can take 10-30 minutes depending on network speed.

## Configuration

- **Model**: qwen3:72b (Ollama)
- **Gateway Port**: 18789
- **Ollama API Port**: 11434
- **Auth Token**: gbagabond

## Volume

- `openclaw_data` → `/root` (contains both `.openclaw` and `.ollama` directories)

## Access

The gateway is available at `https://koloclaw.fly.dev` with the auth token `gbagabond`.