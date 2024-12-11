provider "aws" {
  region = var.region
}

# Creating VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
# Create Public Subnet a
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-a"
  }
}

# Create Private Subnet A
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

# Create Public Subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-b"
  }
}

# Create Private Subnet B
resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "private-subnet-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet-gateway"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# Route for Public Subnets
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Tables with Public Subnets
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public.id
}

# Security Group for EC2 Instance (SSM)
resource "aws_security_group" "allow_ssm" {
  name        = "allow_ssm"
  description = "Allow access through SSM"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (Wazuh)
resource "aws_instance" "wazuh_server" {
  ami           = "ami-0146fc9ad419e2cfd"  
  instance_type = "t3.xlarge"
  subnet_id     = aws_subnet.private_subnet_a.id
  security_groups = [aws_security_group.allow_ssm.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_role.name
  tags = {
    Name = "Wazuh EC2 Instance"
  }
}

# IAM Role and Policy for EC2 Instance to use SSM
resource "aws_iam_instance_profile" "ssm_role" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "SSMPolicy"
  description = "Allow EC2 access via Session Manager"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "ssm:DescribeInstanceInformation"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = [
          "ssm:StartSession",
          "ssm:SendCommand"
        ]
        Effect    = "Allow"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  policy_arn = aws_iam_policy.ssm_policy.arn
  role       = aws_iam_role.ssm_role.name
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket"
  acl    = "private"
  tags = {
    Name = "Terraform State"
  }
}

