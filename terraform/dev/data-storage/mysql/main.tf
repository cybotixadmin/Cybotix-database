

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

# Subnet
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a" 
  map_public_ip_on_launch = true # Necessary for RDS to be accessible from the internet
  tags = {
    Name = "example-subnet"
  }
}

resource "aws_subnet" "example_2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b" # Ensure it's a different AZ from the first subnet
  map_public_ip_on_launch = false
  tags = {
    Name = "example-subnet-2"
  }
}

resource "aws_db_subnet_group" "example" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.example.id, aws_subnet.example_2.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_eip" "example" {
  domain = "vpc"
  associate_with_private_ip = "10.0.0.11"
  depends_on = [aws_internet_gateway.example]
    tags = {
    Name = "example-vpc"
  }
}




resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id  # Assuming 'aws_subnet.example' is your public subnet
}

# Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
    tags = {
    Name = "example-vpc"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
 
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.example_2.id   # Assuming 'aws_subnet.example_2' is your private subnet for RDS
  route_table_id = aws_route_table.private.id
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


# Security Group
resource "aws_security_group" "example" {
  name        = "mysql-rds-sg"
  description = "Allow external IP ranges to connect to RDS MySQL"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["86.0.0.0/8", "0.0.0.0/0" ] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # allows all protocols
    cidr_blocks = ["0.0.0.0/0"] # allows traffic to all IPs
  }
}

# RDS Instance
resource "aws_db_instance" "example" {
  engine               = "mysql"
  identifier           = "myrdsinstance"
  allocated_storage    =  20
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "myrdsuser"
  password             = "myrdspassword"
  publicly_accessible  = "true"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.example.id]
  
    tags = {
    Name = "example-vpc"
  }
}