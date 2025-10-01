#!/bin/bash
# Log all output to a file for troubleshooting
exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

# Update and install system packages (Amazon Linux 2023 uses dnf)
echo "Checking for Amazon Linux 2023 release updates..."
dnf check-release-update || true

echo "Applying Amazon Linux 2023 release update if available..."
dnf upgrade -y || true

echo "Updating system packages..."
dnf update -y

echo "Installing Python 3, pip, git, nodejs, docker, unzip, wget..."
dnf install -y python3 python3-pip git unzip wget

# Install Node.js (for Angular frontend, if needed)
echo "Installing Node.js..."
# Amazon Linux 2023 may have nodejs20 available directly
dnf install -y nodejs

# Install Docker
echo "Installing Docker..."
dnf install -y docker
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker

# Upgrade pip
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# Print installed versions for debugging
python3 --version
pip3 --version
git --version
docker --version
node --version || true
npm --version || true

echo "User data script execution completed successfully."
