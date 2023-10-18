# Add the ID of the VPC to the other confurations in the Dev env.
output "aws_vpc_example_id" {
  value = aws_vpc.example.id
}

output "subnet_db_id" {
  value = aws_subnet.example.id
}

output "subnet_web_id" {
  value = aws_subnet.example_2.id
}


