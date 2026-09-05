terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "MLOpsDeveloper-872792314793"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "mlops" {
  key_name   = var.key_name
  public_key = file("~/.ssh/mlops-key.pub")
}

resource "aws_security_group" "mlops" {
  name        = "mlops-security-group"
  description = "Security group for MLOps project"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["59.94.122.32/32"]
  }

  ingress {
    description = "FastAPI"
    from_port   = 8000
    to_port     = 8000
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

resource "aws_instance" "mlops" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = aws_key_pair.mlops.key_name

  security_groups = [
    aws_security_group.mlops.name
  ]

  tags = {
    Name = "mlops-ec2"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/mlops-key")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo mkdir -p /opt/mlops-app"
    ]
  }

  provisioner "file" {
    source      = "../app/main.py"
    destination = "/tmp/main.py"
  }

  provisioner "file" {
    source      = "../app/requirements.txt"
    destination = "/tmp/requirements.txt"
  }

  provisioner "file" {
    source      = "../app/Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/main.py /opt/mlops-app/main.py",
      "sudo mv /tmp/requirements.txt /opt/mlops-app/requirements.txt",
      "sudo mv /tmp/Dockerfile /opt/mlops-app/Dockerfile",
      "cd /opt/mlops-app",
      "sudo docker build -t mlops-api .",
      "sudo docker rm -f mlops-api || true",
      "sudo docker run -d --name mlops-api --restart unless-stopped -p 8000:8000 mlops-api"
    ]
  }

  provisioner "file" {
    source      = "../scripts/healthcheck.sh"
    destination = "/tmp/healthcheck.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/healthcheck.sh /opt/mlops-app/healthcheck.sh",
      "sudo chmod +x /opt/mlops-app/healthcheck.sh",
      "echo '*/5 * * * * /opt/mlops-app/healthcheck.sh >> /var/log/mlops-healthcheck.log 2>&1' | sudo crontab -"
    ]
  }
}