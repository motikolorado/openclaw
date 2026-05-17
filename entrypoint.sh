#!/bin/sh
set -e

echo "=== OpenClaw Fly.io Entry Point ==="

# Fix permissions on every start
mkdir -p /root/.openclaw
chown -R 1000:1000 /root 2>/dev/null || true
chmod -R 755 /root

# Set required config (safe to run every time)
echo "Setting allowed origin..."
openclaw config set gateway.controlUi.allowedOrigins '["https://koloclaw.fly.dev"]'

echo "Setting gateway mode..."
openclaw config set gateway.mode local

echo "Setting gateway token..."
openclaw config set gateway.auth.token gbagabond

echo "Starting Gateway..."
exec openclaw gateway
