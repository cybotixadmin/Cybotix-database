provider "aws" {
  region = "eu-west-1"
   shared_credentials_files = [".aws/credentials"]
  profile                 = "terraform_deployment"
}

# VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

# Public Subnet (for NAT Gateway)
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "example-public-subnet"
  }
}

# Private Subnet (for RDS)
resource "aws_subnet" "example_2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  tags = {
    Name = "example-private-subnet"
  }
}

# Security Group for RDS
resource "aws_security_group" "example" {
  name        = "mysql-rds-sg"
  description = "Allow external IP ranges to connect to RDS MySQL"
  vpc_id      = aws_vpc.example.id

  # Ingress rule
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # allows all protocols
    cidr_blocks = ["0.0.0.0/0"] # allows traffic to all IPs
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "example" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.example.id, aws_subnet.example_2.id]
  tags = {
    Name = "My DB Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "user"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.example.id]
}

# Elastic IP for NAT Gateway
resource "aws_eip" "example" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.example_2.id
  route_table_id = aws_route_table.private.id
}

# Internet Gateway and Route Table for Public Subnet
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.public.id
}
