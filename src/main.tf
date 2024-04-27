terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "s3_bucket" {
    source = "./modules/s3_bucket"
}