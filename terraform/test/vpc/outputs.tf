# Add the ID of the VPC to the other confurations in the Test env.
output "vpc_id" {
  value = aws_vpc.test_cybotix_api.id
}

output "subnet_db_id" {
  value = aws_subnet.test_cybotix_api_db.id
}

output "subnet_web_id" {
  value = aws_subnet.test_cybotix_api_web.id
}

# Add the following output to view the allocated Elastic IP in the Terraform apply command result
output "public_ip" {
  value = aws_eip.test_cybotix_api.public_ip
}

