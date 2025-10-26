provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.13.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}