terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

#Used for obtaining external management IP of terraform workstation
provider "http" {}
