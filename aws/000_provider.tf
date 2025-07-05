## AWS Provider 설정
provider "aws" {
  # profile = var.terraform_aws_profile
  region = var.aws_region
  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
  }
}