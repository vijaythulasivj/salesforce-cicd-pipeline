# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18

# Install dependencies for SF CLI
RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli 

# Install legacy SFDX CLI (required for force:mdapi:deploy)
RUN sf plugins install @salesforce/sfdx-plugin

# Verify SF CLI
RUN sf --version 

# Verify SFDX CLI
RUN sfdx --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
