terraform {

  required_version = "1.9.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "5.56.0"
    }

  }

}

provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "gordonmurray"
}