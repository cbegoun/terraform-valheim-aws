terraform {
  required_version = "~> 1.0"
  backend "remote" {
    organization = "terraform_cbegoun"

    workspaces {
      name = "terraform-valheim-aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.14.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "github" {
  token = var.github_token
}