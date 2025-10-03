#!/bin/bash
set -e

APP_NAME=asset-predict-web
APP_DIR=/opt/$APP_NAME
REPO_URL="https://github.com/ManoelSilva/asset-predict-web"
BRANCH=main

# Remove existing project directory if it exists
if [ -d "$APP_DIR" ]; then
  rm -rf "$APP_DIR"
fi

# Clone the project from git
git clone --branch $BRANCH $REPO_URL $APP_DIR

# Ensure ec2-user owns all files and has write permissions
chown -R ec2-user:ec2-user $APP_DIR
chmod -R u+rwX $APP_DIR

# Install Node.js dependencies and build the Angular app
cd $APP_DIR
sudo -u ec2-user npm install
sudo -u ec2-user npx ng build --configuration production

# Install nginx if not present
dnf install -y nginx

# Copy built files to nginx html directory
rm -rf /usr/share/nginx/html/*
cp -r $APP_DIR/dist/asset-predict-web/* /usr/share/nginx/html/

# Set permissions for nginx html directory
chown -R nginx:nginx /usr/share/nginx/html

# Enable and restart nginx
systemctl enable nginx
systemctl restart nginx

echo "Asset Predict Web deployed and served via nginx."
