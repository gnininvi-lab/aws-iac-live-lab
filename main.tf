terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "folly-tfstate-bucket" 
    key    = "self-service-lab/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "analytics_storage" {
  source      = "./modules/secure_bucket"
  bucket_name = "corp-analytics-data-unique-suffix" # S3 names must be globally unique
  environment = "Prod"
}

