## Setup Instructions
# Clone the Repository
First, clone the repository to your local machine:
git clone https://github.com/sukheshvallabhu/assessment.git
cd assessment

1. Ensure you have Terraform installed.
2. Initialize Terraform:
      terraform init
3. Apply the Terraform configuration to deploy infrastructure:
   terraform apply
4. SSH into the EC2 instance using Session Manager:
   aws ssm start-session --target <instance-id>
5. Run the setup script to install Docker and Wazuh:
   ./setup.sh

## Access Information
- Wazuh Web UI: `http://<EC2-public-IP>:55000`

## Basic Testing Steps
1. Verify Docker containers are running:
   docker ps
2. Check Wazuh manager logs:
   docker logs wazuh-manager
3. Access the Wazuh Web UI and verify the status of the system.

