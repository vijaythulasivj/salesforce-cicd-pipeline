# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18

# Install dependencies for SF CLI
RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli

# Install legacy Salesforce CLI (sfdx)
RUN curl -sL https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-x64.tar.xz | tar xJ && \
    mkdir -p /usr/local/sfdx && \
    mv sfdx /usr/local/sfdx && \
    /usr/local/sfdx/install

# Add sfdx to PATH
ENV PATH="/root/.local/share/sfdx/bin:$PATH"

# Verify both CLIs
RUN sf --version && sfdx --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
