provider "aws" {
  region = var.region
  shared_credentials_files = [".aws/credentials"]
  profile = "terraform_deployment"

}


resource "aws_db_subnet_group" "test_db" {
  name       = "test-db-subnet-group"
  subnet_ids = [var.subnet_db_id, var.subnet_web_id]
  tags = {
    Name = "test-env My DB Subnet Group"
  }
}


# Security Group
resource "aws_security_group" "test" {
  name        = "test-mysql-rds-sg"
  description = "Allow external IP ranges to connect to RDS MySQL"
  vpc_id      = var.vpc_id

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
  
  tags = {
    Name = "test-env"
  }
}

# RDS Instance
resource "aws_db_instance" "test_cybotix_db" {
  engine               = "mysql"
  identifier           = "test-cybotix-rds-instance"
  allocated_storage    =  20
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "myrdsuser"
  password             = "myrdspassword"
  publicly_accessible  = "true"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.test_db.name
  vpc_security_group_ids = [aws_security_group.test.id]
  
  tags = {
    Name = "test-env"
  }
}