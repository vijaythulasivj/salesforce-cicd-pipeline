# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18

# Install dependencies for SF CLI
RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli 

# Download and install legacy Salesforce CLI (sfdx)
RUN curl -Lo sfdx.tar.xz https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-x64.tar.xz && \
    tar -xf sfdx.tar.xz && \
    ./sfdx/install && \
    rm -rf sfdx sfdx.tar.xz


# Verify SF CLI
RUN sf --version 

# Verify SFDX CLI
RUN sfdx --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
