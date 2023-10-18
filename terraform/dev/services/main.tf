

provider "aws" {
  region = var.region
  shared_credentials_files = [".aws/credentials"]
  profile                 = "terraform_deployment"

}



resource "aws_security_group" "nodejs_sg" {
  name        = "nodejs_sg"
  description = "Allow incoming traffic on port 80 and 22"

  vpc_id      = var.vpc_id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "dev-env"
  }
}

resource "aws_instance" "nodejs_app" {
  ami           = "ami-0dab0800aa38826f2" # Amazon Linux 2023 AMI. Note: This may change. Check AWS for the latest.
  instance_type = "t2.micro"

  key_name = aws_key_pair.deployer.key_name

vpc_security_group_ids = [aws_security_group.nodejs_sg.id]


 subnet_id     = aws_subnet.example.id

 user_data = <<-EOF
              #!/bin/bash
              yum update -y
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
              . ~/.nvm/nvm.sh
              nvm install node
              
              # Install git and clone your repository
              yum install -y git
              git clone https://github.com/cybotixadmin/Cybotix-server-API.git /opt/cybotixserver-api-dev

              # Navigate to your app directory, install dependencies, and start your app
              cd /opt/cybotixserver-api-dev
              npm install
              npm start
              EOF

  tags = {
    Name = "dev-env"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("../.ssh/id_rsa.pub") # Make sure you have your public key at this location
}




resource "aws_eip" "nodejs_eip" {
domain = "vpc"
  instance = aws_instance.nodejs_app.id
}



