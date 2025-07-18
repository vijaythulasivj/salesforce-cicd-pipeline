# Use the official Salesforce CLI image with both sf and sfdx
FROM salesforce/salesforcedx:latest

# Install additional tools if needed
RUN apt-get update && apt-get install -y unzip git bash curl xz-utils && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Optional: Verify CLIs
RUN sf --version && sfdx --version

CMD ["bash"]
