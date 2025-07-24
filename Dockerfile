FROM node:18

RUN apt-get update && apt-get install -y bash curl git && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI via npm, which is officially recommended on that page
RUN npm install -g @salesforce/cli@latest

RUN sf --version

WORKDIR /app

CMD ["bash"]
