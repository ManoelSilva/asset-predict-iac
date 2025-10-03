#!/bin/bash
set -e

# Usage: sudo EC2_HOST=your_EC2_HOST_here bash deploy_asset_predict_model.sh

APP_NAME=asset-predict-model
APP_DIR=/opt/$APP_NAME
REPO_URL="https://github.com/ManoelSilva/asset-predict-model"
BRANCH=main
PYTHON_BIN=python3.12
VENV_DIR=$APP_DIR/venv
SERVICE_FILE=/etc/systemd/system/$APP_NAME.service

# Check for MOTHERDUCK_TOKEN
if [ -z "$MOTHERDUCK_TOKEN" ]; then
  echo "Error: MOTHERDUCK_TOKEN environment variable is not set."
  exit 1
fi

# Check for EC2_HOST
if [ -z "$EC2_HOST" ]; then
  echo "Error: EC2_HOST environment variable is not set."
  exit 1
fi

# Remove existing project directory if it exists
if [ -d "$APP_DIR" ]; then
  rm -rf "$APP_DIR"
fi

# Clone or update the project from git
if [ ! -d "$APP_DIR/.git" ]; then
  git clone --branch $BRANCH $REPO_URL $APP_DIR
else
  cd $APP_DIR
  git fetch origin
  git checkout $BRANCH
  git pull origin $BRANCH
fi

# Ensure ec2-user owns all files and has write permissions
chown -R ec2-user:ec2-user $APP_DIR
chmod -R u+rwX $APP_DIR

# Set up virtual environment
if [ ! -d "$VENV_DIR" ]; then
  $PYTHON_BIN -m venv $VENV_DIR
fi
source $VENV_DIR/bin/activate

# Install requirements
pip install --upgrade pip
pip install -r $APP_DIR/requirements.txt

deactivate

# Replace PUBLIC_IP in swagger.yml with the actual ec2 host IP
SWAGGER_FILE=$APP_DIR/src/b3/config/web_api/swagger/swagger.yml
if [ -f "$SWAGGER_FILE" ]; then
  sed -i "s|http://PUBLIC_IP:5001|http://$EC2_HOST:5001|g" "$SWAGGER_FILE"
fi

# Create systemd service
cat <<EOF > $SERVICE_FILE
[Unit]
Description=Asset Predict Model API
After=network.target

[Service]
User=ec2-user
WorkingDirectory=$APP_DIR/src
Environment="PYTHONUNBUFFERED=1"
Environment="environment=AWS"
Environment="MOTHERDUCK_TOKEN=$MOTHERDUCK_TOKEN"
ExecStart=$VENV_DIR/bin/python3.12 $APP_DIR/src/web_api.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
systemctl daemon-reload
systemctl enable $APP_NAME
systemctl restart $APP_NAME
