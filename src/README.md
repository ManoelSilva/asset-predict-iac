# Asset Predict Infrastructure (Terraform)

This Terraform configuration provisions an AWS EC2 instance to host and serve the following projects:
- asset-data-lake (Python/Flask)
- asset-predict-model (Python/Flask)
- asset-predict-web (Angular)

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
- `variables.tf`: Input variables
- `outputs.tf`: Outputs for instance access
- `user_data.sh`: Bootstraps the instance with required software
- `deploy_asset_data_lake.sh`: Automates deployment and service setup for asset-data-lake
