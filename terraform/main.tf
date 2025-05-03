terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 1) VPC with public & private subnets (v5.x handles removed classiclink args)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.21.0"

  name            = "color-vpc"
  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# 2) Simple RDS instance in private subnets (free-tier eligible)
resource "aws_db_subnet_group" "default" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier             = var.db_identifier
  allocated_storage      = var.db_allocated_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                   = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [module.vpc.default_security_group_id]

  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_type           = "gp2"
  apply_immediately      = true
}

# 3) ECR repos for each microservice
resource "aws_ecr_repository" "services" {
  for_each = toset(var.service_names)

  name = each.key

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
