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

# Remove old files from previous deploy
rm -rf /usr/share/nginx/html/*

# Copy built files to nginx html directory
cp -r $APP_DIR/dist/asset-predict-web/* /usr/share/nginx/html/

# Set permissions for nginx html directory
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html
# Set SELinux context if SELinux is enabled (safe to run regardless)
chcon -R -t httpd_sys_content_t /usr/share/nginx/html || true

# Copy nginx config from repo to nginx conf.d directory
cp /Users/ctw04461/Documents/personal/projects/asset-predict-iac/src/asset-predict-web-nginx.conf /etc/nginx/conf.d/asset-predict-web.conf

# Reload nginx to apply new config
systemctl enable nginx
nginx -t && systemctl reload nginx

echo "Asset Predict Web deployed and served via nginx."
