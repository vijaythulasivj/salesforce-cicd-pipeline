FROM node:18

RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI using official install script
RUN curl -sSL https://developer.salesforce.com/media/salesforce-cli/sf-install-linux.sh | bash

# Verify sf CLI installation
RUN sf --version

WORKDIR /app

CMD ["bash"]
