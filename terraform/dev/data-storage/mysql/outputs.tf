

# Add the following output to view the allocated Elastic IP in the Terraform apply command result
output "nodejs_app_eip" {
  value = aws_eip.nodejs_eip.public_ip
}