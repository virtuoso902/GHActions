# GitHub Actions Runner - Ephemeral Container
FROM ghcr.io/actions/actions-runner:latest

# Switch to root for package installation
USER root

# Install additional tools that might be needed
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for Docker-outside-of-Docker pattern)
RUN curl -fsSL https://get.docker.com | sh

# Add existing runner user to docker group
RUN usermod -aG docker runner

# Switch back to runner user
USER runner
WORKDIR /home/runner

# Copy the entrypoint script
COPY --chown=runner:runner entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]