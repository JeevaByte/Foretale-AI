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
# IAM Module
################################################################################

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # S3 bucket ARNs (empty initially, will be populated after Phase 2)
  s3_bucket_arns = var.s3_bucket_arns

  # RDS resources (empty initially, will be populated after Phase 2)
  rds_cluster_arn = var.rds_cluster_arn

  tags = var.tags
}

################################################################################
# Cognito Module - Phase 1 (Authentication)
################################################################################

module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment
  enable_mfa   = var.enable_cognito_mfa

  tags = var.tags
}

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
# Phase 2: Database and Storage
################################################################################

################################################################################
# S3 Module
################################################################################

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment

  cors_allowed_origins = var.cors_allowed_origins

  tags = var.tags
}

################################################################################
# RDS Module
################################################################################

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment

  # Network Configuration
  database_subnet_ids   = module.vpc.database_subnet_ids
  rds_security_group_id = module.security_groups.rds_security_group_id

  # RDS Configuration
  engine_version    = var.rds_engine_version
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  storage_type      = var.rds_storage_type
  db_name           = var.rds_db_name
  db_username       = var.rds_db_username

  # Backup Configuration
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = var.rds_backup_window
  maintenance_window      = var.rds_maintenance_window
  skip_final_snapshot     = var.rds_skip_final_snapshot

  # Monitoring
  monitoring_interval         = var.rds_monitoring_interval
  monitoring_role_arn         = module.iam.rds_monitoring_role_arn
  enable_performance_insights = var.rds_enable_performance_insights

  # High Availability
  multi_az                   = var.rds_multi_az
  auto_minor_version_upgrade = var.rds_auto_minor_version_upgrade
  deletion_protection        = var.rds_deletion_protection

  tags = var.tags

  depends_on = [module.vpc, module.security_groups, module.iam]
}

################################################################################
# DynamoDB Module
################################################################################

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment

  billing_mode                  = var.dynamodb_billing_mode
  read_capacity                 = var.dynamodb_read_capacity
  write_capacity                = var.dynamodb_write_capacity
  enable_point_in_time_recovery = var.dynamodb_enable_pitr

  tags = var.tags
}

################################################################################
# Phase 3: Application Layer (API Gateway, Lambda, EKS)
################################################################################

################################################################################
# Lambda Module
################################################################################

module "lambda" {
  source = "./modules/lambda"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # IAM Configuration
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn

  # VPC Configuration
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.lambda_security_group_id]

  # RDS Configuration
  rds_endpoint                = module.rds.db_instance_endpoint
  rds_port                    = module.rds.db_instance_port
  rds_database                = var.rds_db_name
  rds_username                = var.rds_db_username
  secrets_manager_secret_name = module.rds.db_credentials_secret_name

  # ECS Configuration (for task invocation)
  ecs_cluster_uploads         = "arn:aws:ecs:${var.aws_region}:442426872653:cluster/cluster-uploads"
  ecs_cluster_execute         = "arn:aws:ecs:${var.aws_region}:442426872653:cluster/cluster-execute"
  ecs_task_definition_csv     = "arn:aws:ecs:${var.aws_region}:442426872653:task-definition/td-csv-upload:2"
  ecs_task_definition_execute = "arn:aws:ecs:${var.aws_region}:442426872653:task-definition/td-db-process:2"

  # Lambda Layers
  lambda_layer_db_utils_arn = var.lambda_layer_db_utils_arn
  lambda_layer_pyodbc_arn   = var.lambda_layer_pyodbc_arn

  tags = var.tags

  depends_on = [module.iam, module.security_groups, module.vpc]
}

################################################################################
# API Gateway SQL Module
################################################################################

module "api_gateway_sql" {
  source = "./modules/api-gateway-sql"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Cognito Configuration
  cognito_user_pool_arn = var.cognito_user_pool_arn

  # Lambda Integration (SQL database operations)
  lambda_invoke_arn_calling_sql_procedure    = module.lambda.calling_sql_procedure_invoke_arn
  lambda_function_name_calling_sql_procedure = module.lambda.calling_sql_procedure_function_name

  tags = var.tags

  depends_on = [module.lambda, module.iam]
}

################################################################################
# API Gateway ECS Module
################################################################################

module "api_gateway_ecs" {
  source = "./modules/api-gateway-ecs"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Cognito Configuration
  cognito_user_pool_arn = var.cognito_user_pool_arn

  # Lambda Integration (ECS task operations)
  lambda_invoke_arn_ecs_invoker    = module.lambda.ecs_invoker_invoke_arn
  lambda_function_name_ecs_invoker = module.lambda.ecs_invoker_function_name

  lambda_invoke_arn_get_ecs_status    = module.lambda.get_ecs_status_invoke_arn 
  lambda_function_name_get_ecs_status = module.lambda.get_ecs_status_function_name

  tags = var.tags

  depends_on = [module.lambda, module.iam]
}

################################################################################
# EKS Cluster Module
################################################################################

module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment

  # VPC Configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Kubernetes Configuration
  kubernetes_version = var.eks_kubernetes_version

  # Node Group Configuration
  instance_types = var.eks_instance_types
  desired_size   = var.eks_desired_size
  min_size       = var.eks_min_size
  max_size       = var.eks_max_size

  # RDS Integration
  rds_security_group_id      = module.security_groups.rds_security_group_id
  rds_port                   = module.rds.db_instance_port
  secrets_manager_secret_arn = module.rds.db_credentials_secret_arn

  tags = var.tags

  depends_on = [module.vpc, module.security_groups, module.rds]
}

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

  # Security and IAM
  security_group_id         = module.security_groups.ai_server_security_group_id
  iam_instance_profile_name = module.iam.ai_server_instance_profile_name

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

  depends_on = [module.alb, module.iam, module.vpc, module.security_groups]
}
