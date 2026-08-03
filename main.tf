terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # No real AWS credentials are needed yet because our CI pipeline only runs "plan"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

module "analytics_storage" {
  source      = "./modules/secure_bucket"
  bucket_name = "corp-analytics-data"
  environment = "prod" # ❌ This breaks the "Dev/Stage/Prod" capitalization rule
}
