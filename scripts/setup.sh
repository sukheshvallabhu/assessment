#!/bin/bash

# Updating the system with updates
sudo yum update -y

# Installing Docker
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Installing Docker Compose
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Deploying Wazuh using Docker Compose
cd /home/ec2-user
git clone https://github.com/wazuh/wazuh-docker.git
cd wazuh-docker

# Starting Wazuh using Docker Compose
docker-compose up -d

