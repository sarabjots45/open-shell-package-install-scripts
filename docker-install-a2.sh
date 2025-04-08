#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
log() {
    echo -e "\n==> $1\n"
}

# Check if Docker is already installed
if command -v docker &>/dev/null; then
    log "Docker is already installed. Skipping Docker installation."
else
    log "Installing Docker..."
    sudo amazon-linux-extras enable docker
    sudo yum clean metadata
    sudo yum install -y docker
fi

# Enable and start Docker service
log "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the docker group
CURRENT_USER=$(whoami)
if groups "$CURRENT_USER" | grep &>/dev/null "\bdocker\b"; then
    log "User '$CURRENT_USER' is already in the docker group."
else
    log "Adding user '$CURRENT_USER' to the docker group..."
    sudo usermod -aG docker "$CURRENT_USER"
    log "You may need to log out and log back in for group changes to take effect."
fi

# Install Docker Compose
DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose"
if [ -x "$DOCKER_COMPOSE_PATH" ]; then
    log "Docker Compose is already installed. Skipping Docker Compose installation."
else
    log "Installing the latest stable Docker Compose..."
    # Get latest release version
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K[^"]+')
    
    sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "$DOCKER_COMPOSE_PATH"
    sudo chmod +x "$DOCKER_COMPOSE_PATH"
fi

# Print versions
log "Docker version:"
docker --version

log "Docker Compose version:"
docker-compose --version
