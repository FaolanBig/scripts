#!/bin/bash

###############################################################
### Install the latest version of Docker on a Linux system  ###
### RUN THIS SCRIPT AS ROOT OR WITH SUDO OR RUN             ###
### `curl -L https://docker-install-scripts.bigvault.cloud` ###
###############################################################

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with "
  exit
fi

# Remove any old versions of Docker if they exist
apt remove -y $(dpkg --get-selections docker.io docker-compose docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
 tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

# Install the latest version of Docker Engine and containerd
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Verify Docker installation
docker --version
docker run hello-world

echo "Docker installation completed successfully."
