# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18

# Install dependencies for SF CLI and sfdx CLI installer
RUN apt-get update && apt-get install -y bash curl git unzip && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli

# Install Salesforce DX CLI (sfdx) - legacy CLI needed for check-only deploy
RUN curl -Lo sfdx-linux-amd64.tar.xz https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz && \
    tar xJf sfdx-linux-amd64.tar.xz && \
    ./sfdx/install && \
    rm -rf sfdx-linux-amd64.tar.xz sfdx

# Verify both CLIs
RUN sf --version
RUN sfdx --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
