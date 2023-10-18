provider "aws" {
  region = "eu-west-1"
   shared_credentials_files = [".aws/credentials"]
  profile                 = "terraform_deployment"
}

# VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
   enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "dev-env"
  }
}

# Subnet
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_1 
  map_public_ip_on_launch = true # Necessary for RDS to be accessible from the internet
  tags = {
    Name = "development-env"
  }
}



# Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
    tags = {
    Name = "development-env"
  }
}


resource "aws_eip" "example" {
  domain = "vpc"
  associate_with_private_ip = "10.0.0.11"
  depends_on = [aws_internet_gateway.example]
    tags = {
    Name = "development-env"
  }
}

resource "aws_subnet" "example_2" {
  vpc_id                  =  aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone_2 # Ensure it's a different AZ from the first subnet
  map_public_ip_on_launch = false
  tags = {
    Name = "development-env"
  }
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id  # Assuming 'aws_subnet.example' is your public subnet
  tags = {
    Name = "development-env"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
  tags = {
    Name = "development-env"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = subnet_db_id   # Assuming 'aws_subnet.example_2' is your private subnet for RDS
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
  tags = {
    Name = "development-env"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.example_2.id
  route_table_id = aws_route_table.public.id
  
}
