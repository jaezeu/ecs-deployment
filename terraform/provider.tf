terraform {
  required_providers {
    aws = {
      version = "~> 6.44.0"
    }
  }
  required_version = ">= 1.15.2"
}

provider "aws" {
  region = "ap-southeast-1"
}