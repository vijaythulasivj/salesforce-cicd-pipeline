# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18-alpine

# Install dependencies for SF CLI
RUN apk add --no-cache bash curl git

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli

# Verify installation
RUN sf --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
