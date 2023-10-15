

# Add outputs for connection information
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.example.endpoint
}

output "rds_security_group_id" {
  description = "The Security Group ID associated with the RDS instance"
  value       = aws_security_group.example.id
}
