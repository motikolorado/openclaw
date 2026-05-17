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
RUN mkdir -p /root/.openclaw && chown -R 1000:1000 /root

# Expose the dashboard port
EXPOSE 18789
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
