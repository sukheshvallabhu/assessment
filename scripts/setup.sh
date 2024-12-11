#!/bin/bash

# Function to check the last command's exit status
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting."
    exit 1
  fi
}
# Updating the system with updates
sudo yum update -y
check_error "System update"

# Installing Docker
sudo amazon-linux-extras install docker -y
check_error "Docker installation"
sudo service docker start
check_error "Docker service start"
sudo usermod -a -G docker ec2-user
check_error "Adding ec2-user to Docker group"

# Installing Docker Compose
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
check_error "Docker Compose download"
sudo chmod +x /usr/local/bin/docker-compose
check_error "Docker Compose permissions update"

# Check if Docker Compose was successfully installed
docker-compose --version
check_error "Docker Compose verification"

# Deploying Wazuh using Docker Compose
cd /home/ec2-user
git clone https://github.com/wazuh/wazuh-docker.git
check_error "Git clone of Wazuh Docker repository"
cd wazuh-docker

# Starting Wazuh using Docker Compose
docker-compose up -d
check_error "Docker Compose up for Wazuh"
# Wait for containers to be fully started
sleep 30
# Verify the containers are running
docker ps
check_error "Docker ps"
echo "Wazuh deployment completed successfully."

