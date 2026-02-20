# Use Node 22 as required by OpenClaw
FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install OpenClaw globally
RUN npm install -g openclaw mcporter

# Create a directory for persistent data
RUN mkdir -p /root/.openclaw

# Expose the dashboard port
EXPOSE 18789

# Start the gateway
# We use --host 0.0.0.0 so Fly.io can route traffic to it
CMD ["openclaw", "gateway", "--port", "18789", "--host", "0.0.0.0"]
