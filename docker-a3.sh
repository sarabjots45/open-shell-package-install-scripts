#!/bin/bash

set -e

log() {
    echo -e "\n==> $1\n"
}

# Install required packages
log "Installing prerequisites..."
sudo dnf install -y dnf-plugins-core

# Add Docker's CentOS 9 Stream repo (works with Amazon Linux 2023)
log "Adding Docker repo (CentOS 9 Stream)..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo sed -i 's/\$releasever/9/g' /etc/yum.repos.d/docker-ce.repo

# Install Docker packages
log "Installing Docker Engine and Docker Compose plugin..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
log "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
CURRENT_USER=$(whoami)
if groups "$CURRENT_USER" | grep -q "\bdocker\b"; then
    log "User '$CURRENT_USER' is already in the docker group."
else
    log "Adding user '$CURRENT_USER' to the docker group..."
    sudo usermod -aG docker "$CURRENT_USER"
    log "You may need to log out and back in for changes to take effect."
fi

# Confirm installation
log "Docker version:"
docker --version

log "Docker Compose version:"
docker compose version
