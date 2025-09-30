output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.asset_predict_host.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.asset_predict_host.public_dns
}
