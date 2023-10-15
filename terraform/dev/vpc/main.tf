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
    Name = "example-vpc"
  }
}

