#variable "access_key" {
#    description = "Access key to AWS console"
#}
#variable "secret_key" {
#    description = "Secret key to AWS console"
#}
variable "region" {
    description = "AWS region"
}
variable "vpc_id" {
    description = "VPC identifier, collected from execution of scripts in the /vpc/ directory"
}


