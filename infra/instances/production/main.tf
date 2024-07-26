terraform {
  backend "remote" {
    organization = "tolikhalas"

    workspaces {
      name = "giffy-production"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48"
    }
  }

  required_version = ">= 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "production_public_key" {
  description = "Production environment public key value"
  type        = string
}

variable "base_ami_id" {
  description = "Base AMI ID"
  type        = string
}

resource "aws_key_pair" "production_key" {
  key_name   = "production-key"
  public_key = var.production_public_key

  tags = {
    "Name" = "production_public_key"
  }
}

resource "aws_instance" "production_giffy" {
  ami                    = var.base_ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0ae68ce633899b333"]
  key_name               = aws_key_pair.production_key.key_name

  tags = {
    "Name" = "production_giffy"
  }
}

output "production_dns" {
  value = aws_instance.production_giffy.public_dns
}