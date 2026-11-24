#!/bin/bash

### README ########################################################
# This script installs the latest version of the Docker Engine    #
# onto your machine. If not run as root it will promt for sudo    #
# password. To quickly execute it without manually downloading    #
# it, simply run one of the following commands in your terminal:  #
# `curl -L https://docker-install-script.bigvault.cloud | bash`   #
# `wget -qO- https://docker-install-script.bigvault.cloud | bash` #
###################################################################

if [ "$EUID" -ne 0 ]; then
  exec sudo -- "$0" "$@"
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
