# Use an official lightweight node image as base (SF CLI is Node-based)
FROM node:18

# Install dependencies for SF CLI
RUN apt-get update && apt-get install -y bash curl git xz-utils && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf) from official tarball
RUN curl -sSL https://developer.salesforce.com/tools/salesforcecli/sf-linux-x64.tar.xz | tar -xJ -C /usr/local/bin --strip-components=1 sf-linux-x64/sf

# Make sure sf CLI is executable and in PATH
RUN chmod +x /usr/local/bin/sf

# Verify SF CLI
RUN sf --version

# Set working directory
WORKDIR /app

# Default command (optional)
CMD ["bash"]
