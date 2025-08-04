FROM node:18

RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf CLI)
RUN npm install -g @salesforce/cli@2.98.6

# Install legacy Salesforce CLI (sfdx CLI)
RUN npm install -g sfdx-cli@7.150.1

# Clear npm cache
RUN npm cache clean --force

# Verify both CLIs installed
RUN sf --version
RUN sfdx --version

WORKDIR /app

CMD ["bash"]
