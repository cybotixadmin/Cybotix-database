variable "region" {
    description = "AWS region"
}
variable "vpc_id" {
    description = "VPC identifier, collected from execution of scripts in the /vpc/ directory"
}

variable "subnet_db_id" {
    description = "VPC subnet identifier, collected from execution of scripts in the /vpc/ directory"
}

variable "subnet_web_id" {
    description = "VPC subnet identifier, collected from execution of scripts in the /vpc/ directory"
}

variable "key_name" {
    description = "ssh key"
}

