FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install Openclaw
RUN pip install openclaw

# Install required dependencies for Telegram support (if necessary)

# Copy the application code
COPY . .

# Set environment variables (can be overridden by deployment)
ENV TELEGRAM_API_KEY=your_telegram_api_key_here

# Default command to launch Openclaw with Telegram
CMD ["openclaw", "--telegram"]