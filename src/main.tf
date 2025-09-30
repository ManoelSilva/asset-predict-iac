provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "asset_predict_host" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type, update as needed
  instance_type = "t3.large"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.asset_predict_sg.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "asset-predict-host"
  }
}

resource "aws_security_group" "asset_predict_sg" {
  name        = "asset-predict-sg"
  description = "Allow HTTP, HTTPS, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
