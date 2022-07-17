terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-07-basic-task1-states"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-07-basic-task1-states"
    key    = ".terarform/terraform.tfstate"
    region = "us-west-2"

    encrypt = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical

}

locals {
  instance_type_map = {
    stage = "t2.nano"
    prod  = "t2.micro"
  }

  instance_count_map = {
    stage = 1
    prod  = 2
  }

  instances = {
    "t2.nano"  = data.aws_ami.ubuntu.id
    "t2.micro" = data.aws_ami.ubuntu.id
  }
}

resource "aws_instance" "app_server_count" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type_map[terraform.workspace]
  count         = local.instance_count_map[terraform.workspace]

  tags = {
    Name = "app_server_count-${terraform.workspace}-${count.index}"
  }
}

resource "aws_instance" "app_server_foreach" {
  for_each = local.instances

  ami           = each.value
  instance_type = each.key

  tags = {
    Name = "app_server_foreach-${terraform.workspace}-${each.key}"
  }

  lifecycle {
    create_before_destroy = true
  }
}