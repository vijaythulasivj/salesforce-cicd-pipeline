FROM node:18

# Install dependencies
RUN apt-get update && apt-get install -y bash curl git unzip xz-utils && rm -rf /var/lib/apt/lists/*

# Install unified Salesforce CLI
RUN npm install -g @salesforce/cli

# Install legacy SFDX functionality via plugin
RUN sf plugins install @salesforce/sfdx-plugin

# Verify both CLIs
RUN sf --version && sf plugins

# Set working directory
WORKDIR /app

CMD ["bash"]
