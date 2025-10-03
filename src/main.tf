provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "latest_amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_key_pair" "local_key" {
  key_name   = "asset-predict-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_iam_instance_profile" "labrole_profile" {
  name = "labrole-instance-profile"
  role = "LabRole"
}

resource "aws_instance" "asset_predict_host" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux_ami.value
  instance_type = "t3.large"
  iam_instance_profile = aws_iam_instance_profile.labrole_profile.name
  key_name      = aws_key_pair.local_key.key_name

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

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5002
    to_port     = 5002
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
