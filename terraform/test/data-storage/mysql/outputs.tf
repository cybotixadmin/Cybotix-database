



# Add the following output to view the allocated Elastic IP in the Terraform apply command result
output "address" {
  value = aws_db_instance.test_cybotix_db.address
}