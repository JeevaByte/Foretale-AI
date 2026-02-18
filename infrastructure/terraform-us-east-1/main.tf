################################################################################
# ForeTale Application - Main Terraform Configuration
# Phase 1: Core Infrastructure and Networking
################################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure after creating S3 bucket for state
  # backend "s3" {
  #   bucket         = "foretale-terraform-state"
  #   key            = "infrastructure/terraform.tfstate"
  #   region         = "us-east-2"
  #   encrypt        = true
  #   dynamodb_table = "foretale-terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Application = "ForeTale"
    }
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

################################################################################
# IAM Module (SKIPPED - Shared across regions, defined in us-east-2)
################################################################################

# module "iam" {
#   source = "./modules/iam"
#   # (uses existing us-east-2 roles)
# }

################################################################################
# Cognito Module - Phase 1 (SKIPPED - Shared across regions, defined in us-east-2)
################################################################################

# module "cognito" {
#   source = "./modules/cognito"
#   # (uses existing us-east-2 cognito pools)
# }

################################################################################
# Security Groups
################################################################################

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr

  tags = var.tags
}

################################################################################
# Phase 2: Database and Storage (SKIPPED - Shared across regions)
################################################################################

################################################################################
# S3 Module (SKIPPED - Shared across regions, defined in us-east-2)
################################################################################

# module "s3" {
#   source = "./modules/s3"
#   # (uses existing us-east-2 S3 buckets)
# }

################################################################################
# RDS Module (SKIPPED - Shared across regions, defined in us-east-2)
################################################################################

# module "rds" {
#   source = "./modules/rds"
#   # (uses existing us-east-2 RDS instance)
# }

################################################################################
# DynamoDB Module (SKIPPED - Shared across regions, defined in us-east-2)
################################################################################

# module "dynamodb" {
#   source = "./modules/dynamodb"
#   # (uses existing us-east-2 DynamoDB tables)
# }

################################################################################
# Phase 3: Application Layer (SKIPPED - Lambda, API Gateway, EKS)
################################################################################

# Lambda, API Gateway, and EKS modules are defined in us-east-2 and shared
# us-east-1 deployment focuses only on VPC, ALB, and Auto Scaling

################################################################################
# Lambda Module (SKIPPED - Shared in us-east-2)
################################################################################

# module "lambda" { ... }

################################################################################
# API Gateway SQL Module (SKIPPED - Shared in us-east-2)
################################################################################

# module "api_gateway_sql" { ... }

################################################################################
# API Gateway ECS Module (SKIPPED - Shared in us-east-2)
################################################################################

# module "api_gateway_ecs" { ... }

################################################################################
# EKS Cluster Module (SKIPPED - Shared in us-east-2)
################################################################################

# module "eks" { ... }

################################################################################
# KAN-9: Application Load Balancer Module
################################################################################

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id

  # Network Configuration
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id

  # HTTPS Configuration (optional)
  certificate_arn = var.alb_certificate_arn

  tags = var.tags

  depends_on = [module.vpc, module.security_groups]
}

################################################################################
# Data Source: Retrieve existing IAM instance profile from us-east-2
################################################################################

data "aws_iam_instance_profile" "ai_server" {
  name = "foretale-dev-ai-server-profile"
}

################################################################################
# KAN-9: Auto Scaling Module
################################################################################

module "autoscaling" {
  source = "./modules/autoscaling"

  project_name = var.project_name
  app_name     = "foretale-app"
  environment  = var.environment
  aws_region   = var.aws_region

  # Network Configuration
  private_subnet_ids = module.vpc.private_subnet_ids

  # Security and IAM (use existing instance profile from us-east-2)
  security_group_id         = module.security_groups.ai_server_security_group_id
  iam_instance_profile_name = data.aws_iam_instance_profile.ai_server.name

  # ALB Integration - Attach ASG to the EC2 target group
  alb_target_group_arn     = module.alb.ai_servers_target_group_arn
  alb_arn_suffix           = module.alb.alb_arn_suffix
  target_group_arn_suffix  = module.alb.ai_servers_target_group_arn_suffix

  # Scaling Configuration
  min_size     = var.asg_min_size
  max_size     = var.asg_max_size
  desired_size = var.asg_desired_size

  # Instance Configuration
  ami_id          = var.ami_id
  instance_type   = var.asg_instance_type
  ebs_volume_size = var.asg_ebs_volume_size

  # Scaling Policies
  cpu_target_utilization = var.cpu_target_utilization
  alb_request_target     = var.alb_request_target

  tags = var.tags

  depends_on = [module.alb, module.vpc, module.security_groups]
}
