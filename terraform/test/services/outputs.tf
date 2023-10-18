

output "www_public_dns" {
  value = aws_instance.test_nodejs_app.public_dns
}
output "www_public_ip" {
  value =  aws_instance.test_nodejs_app.public_ip
}
