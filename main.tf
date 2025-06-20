terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0, < 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-1cf48a7e-0cce-4afc-b29e-8584937eb9e9"
    key            = "fon-automatizacija/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region  = "eu-central-1"
}

