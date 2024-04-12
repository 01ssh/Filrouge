terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }
  cloud {
    organization="SOLCOMPUTING"
    workspaces {
      name=%WORKSPACEINFRA%#replace.WORKSPACEINFRA
      #name="aurora_marcdst"
    }
  }
}

