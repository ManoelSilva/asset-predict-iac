[Leia em português](README.pt-br.md)

# Asset Predict Infrastructure (Terraform)

This Terraform configuration provisions an AWS EC2 instance to host and serve the following projects:
- [asset-data-lake](../asset-data-lake/README.md) (Python/Flask)
- [asset-predict-model](../asset-predict-model/README.md) (Python/Flask)
- [asset-predict-web](../asset-predict-web/README.md) (Angular)

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0.0
- An existing EC2 Key Pair (for SSH access)
- IAM Role named `LabRole` with necessary permissions

## Usage

1. **Initialize Terraform**
   ```sh
   terraform init
   ```
2. **Apply the configuration**
   ```sh
   terraform apply -var="key_name=YOUR_KEY_PAIR_NAME"
   ```
   Replace `YOUR_KEY_PAIR_NAME` with your EC2 key pair name.

3. **Access the instance**
   The public IP and DNS will be output after apply. SSH using:
   ```sh
   ssh -i /path/to/your-key.pem ec2-user@<public_ip>
   ```

4. **Deploy asset-data-lake**
   - Copy the `asset-data-lake` project folder to the EC2 instance (e.g., to `~/asset-data-lake`).
   - Copy `deploy_asset_data_lake.sh` to the EC2 instance (e.g., to `~/deploy_asset_data_lake.sh`).
   - Run the deployment script:
     ```sh
     sudo bash ~/deploy_asset_data_lake.sh
     ```
   - The Flask API will be started as a systemd service and enabled on boot.

5. **Project Deployment**
   The instance will have Python, Node.js, and Docker installed. Project-specific deployment scripts will be added to automate setup for each project.

## Files
- `main.tf`: EC2, security group, and IAM role setup
- `outputs.tf`: Outputs for instance access (public IP and DNS)
- `user_data.sh`: Bootstraps the instance with required software (Python 3.12, Node.js, Docker, Git)
- `deploy_asset_data_lake.sh`: Automates deployment and service setup for asset-data-lake
- `deploy_asset_predict_model.sh`: Automates deployment and service setup for asset-predict-model
- `deploy_asset_predict_web.sh`: Automates deployment and service setup for asset-predict-web
- `asset-predict-web-nginx.conf`: Nginx configuration for serving the Angular frontend

## Environment Variables Required

Before deploying the services, you need to set up the following environment variables:

### For asset-data-lake and asset-predict-model:
```bash
export MOTHERDUCK_TOKEN="your_motherduck_token_here"
export EC2_HOST="your_ec2_public_ip_or_domain"
```

## Complete Deployment Process

1. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform apply -var="key_name=YOUR_KEY_PAIR_NAME"
   ```

2. **Deploy asset-data-lake**
   ```bash
   # On the EC2 instance
   sudo MOTHERDUCK_TOKEN=your_token EC2_HOST=your_ip bash deploy_asset_data_lake.sh
   ```

3. **Deploy asset-predict-model**
   ```bash
   # On the EC2 instance
   sudo MOTHERDUCK_TOKEN=your_token EC2_HOST=your_ip bash deploy_asset_predict_model.sh
   ```

4. **Deploy asset-predict-web**
   ```bash
   # On the EC2 instance
   sudo bash deploy_asset_predict_web.sh
   ```

## Service Endpoints

After deployment, the following services will be available:

- **Frontend (Angular)**: `http://your-ec2-ip/` (port 80)
- **Data Lake API**: `http://your-ec2-ip:5002/` (Flask API)
- **Model API**: `http://your-ec2-ip:5001/` (Flask API)

## Security Considerations

- The security group allows SSH (22), HTTP (80), HTTPS (443), and custom ports (5001, 5002)
- Consider restricting SSH access to your IP range in production
- The instance uses an IAM role (`LabRole`) for AWS service access
- All services run as the `ec2-user` with appropriate permissions

## Cost Estimation

- **EC2 Instance**: t3.large (~$0.0832/hour)
- **Storage**: 8GB gp3 EBS volume (~$0.08/month)
- **Data Transfer**: Minimal for typical usage
- **Total estimated cost**: ~$60-80/month for continuous operation

## Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check service status
   sudo systemctl status asset-data-lake
   sudo systemctl status asset-predict-model
   
   # Check logs
   sudo journalctl -u asset-data-lake -f
   sudo journalctl -u asset-predict-model -f
   ```

2. **Port conflicts**
   ```bash
   # Check if ports are in use
   sudo netstat -tlnp | grep :5001
   sudo netstat -tlnp | grep :5002
   ```

3. **Permission issues**
   ```bash
   # Fix ownership
   sudo chown -R ec2-user:ec2-user /opt/asset-*
   ```

4. **Environment variables not set**
   - Ensure `MOTHERDUCK_TOKEN` and `EC2_HOST` are properly exported
   - Check service files in `/etc/systemd/system/` for environment variables
