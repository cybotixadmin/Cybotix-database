provider "aws" {
  region = var.region
   shared_credentials_files = [".aws/credentials"]
  profile = "terraform_deployment"
}

# VPC
resource "aws_vpc" "test_cybotix_api" {
  cidr_block = "10.0.0.0/16"
   enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "test-env"
  }
}

# Subnet





######
## database/private subnet
######
resource "aws_subnet" "test_cybotix_api_db" {
  vpc_id                  =  aws_vpc.test_cybotix_api.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zone_2 # Ensure it's a different AZ from the first subnet
  map_public_ip_on_launch = false
  tags = {
    Name = "test-env"
  }
}


resource "aws_route_table_association" "test_cybotix_api_db" {
  subnet_id      = aws_subnet.test_cybotix_api_db.id# Assuming 'aws_subnet.example_2' is your private subnet for RDS
  route_table_id = aws_route_table.test_cybotix_api_db.id
}

resource "aws_route_table" "test_cybotix_api_db" {
  vpc_id = aws_vpc.test_cybotix_api.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test_cybotix_api.id
  }
  tags = {
    Name = "test-env"
  }
}


## 
#####
## web/public subnet
#####
resource "aws_subnet" "test_cybotix_api_web" {
  vpc_id                  = aws_vpc.test_cybotix_api.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone_1 
  map_public_ip_on_launch = true # Necessary for RDS to be accessible from the internet
  tags = {
    Name = "test-env"
  }
}

resource "aws_route_table_association" "test_cybotix_api_web" {
  subnet_id      = aws_subnet.test_cybotix_api_web.id
  route_table_id = aws_route_table.test_cybotix_api_web.id
  
}

resource "aws_route_table" "test_cybotix_api_web" {
  vpc_id = aws_vpc.test_cybotix_api.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_cybotix_api.id
  }
  tags = {
    Name = "test-env"
  }
}


## external connection to public subnet


# Internet Gateway
resource "aws_internet_gateway" "test_cybotix_api" {
  vpc_id = aws_vpc.test_cybotix_api.id
    tags = {
    Name = "test-env"
  }
}


resource "aws_eip" "test_cybotix_api" {
  domain = "vpc"
  associate_with_private_ip = "10.0.0.11"
  depends_on = [aws_internet_gateway.test_cybotix_api]
    tags = {
    Name = "test-env"
  }
}

resource "aws_nat_gateway" "test_cybotix_api" {
  allocation_id = aws_eip.test_cybotix_api.id
  subnet_id     = aws_subnet.test_cybotix_api_web.id  # public subnet
  tags = {
    Name = "test-env"
  }
}




