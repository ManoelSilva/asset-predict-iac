#!/bin/bash
set -e

# Update and install system packages
yum update -y

# Install Python 3.12 and pip
amazon-linux-extras enable python3.8
yum install -y python3 python3-pip

# Install Node.js (for Angular frontend)
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# Install Docker
yum install -y docker
groupadd docker || true
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker

# Install Git
yum install -y git

# Upgrade pip
python3 -m pip install --upgrade pip

# Set up firewall (optional, handled by SG)
# firewall-cmd --permanent --add-service=http
# firewall-cmd --permanent --add-service=https
# firewall-cmd --reload

# Placeholder for project deployment steps
