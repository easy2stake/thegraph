terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
    http = {
      source = "hashicorp/http"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
  required_version = ">= 0.13"
}
