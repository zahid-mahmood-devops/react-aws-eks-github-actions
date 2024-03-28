terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.40"  # Ensure this version is compatible with your resources.
    }
  }
}

provider "aws" {
  region = "us-east-2"  # Replace this with your AWS region
  # Optionally, configure your credentials here or via environment variables.
}
