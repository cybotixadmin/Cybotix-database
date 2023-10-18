

provider "aws" {
  region = var.region
  shared_credentials_files = [".aws/credentials"]
  profile                 = "terraform_deployment"

}

resource "aws_key_pair" "test_deployer" {
  key_name   = "test-deployer-key"
  public_key = file("../.ssh/id_rsa.pub") # Make sure you have your public key at this location
}


