FROM node:18

# Install dependencies
RUN apt-get update && apt-get install -y bash curl git unzip xz-utils && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI (sf)
RUN npm install -g @salesforce/cli

# Install Salesforce DX CLI (legacy sfdx)
RUN curl -Lo sfdx.tar.xz https://github.com/salesforcecli/sfdx-cli/releases/download/v7.205.0/sfdx-cli-v7.205.0-linux-x64.tar.xz && \
    mkdir -p /sfdx && \
    tar -xJf sfdx.tar.xz -C /sfdx --strip-components=1 && \
    /sfdx/install && \
    rm -rf sfdx.tar.xz /sfdx

# Verify CLIs
RUN sf --version
RUN sfdx --version

# Set working directory
WORKDIR /app
CMD ["bash"]
