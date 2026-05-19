FROM ollama/ollama:latest

# Install Node 22 + build deps
RUN apt-get update && apt-get install -y \
    curl python3 make g++ git ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install OpenClaw globally
# RUN npm install -g openclaw mcporter

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create data dirs
RUN mkdir -p /root/.openclaw /root/.ollama

EXPOSE 18789 11434 3000

# Start the entrypoint (which handles both ollama and openclaw)
ENTRYPOINT ["/entrypoint.sh"]