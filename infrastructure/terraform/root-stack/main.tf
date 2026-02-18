module "account_vending" {
  source            = "./modules/account_vending"
  client_name       = var.client_name
  client_dev_email  = var.client_dev_email
  client_uat_email  = var.client_uat_email
  client_prod_email = var.client_prod_email
}

module "cidr" {
  source           = "./modules/cidr"
  base_cidr_block  = var.cidr_block
  subnet_cidr_bits = 8
}

module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = var.cidr_block
  public_subnet_cidrs  = module.cidr.public_subnet_cidrs
  private_subnet_cidrs = module.cidr.private_subnet_cidrs
  isolated_subnet_cidrs = module.cidr.isolated_subnet_cidrs
  azs                  = var.azs
  environment          = var.environment
  cost_center          = var.cost_center
  sustainability       = var.sustainability
  create_nat_gateway   = false
}

module "security" {
  source                    = "./modules/security"
  security_admin_account_id = var.security_admin_account_id
  config_role_arn           = var.config_role_arn
}

module "secrets" {
  source                  = "./modules/secrets"
  project_name            = var.project_name
  environment             = var.environment
  tags                    = {}
  
  # Control flags - set to true to create each secret
  create_dev_url_alb_ecs_services  = var.create_dev_url_alb_ecs_services
  create_dev_pinecone_api          = var.create_dev_pinecone_api
  create_dev_langsmith_api         = var.create_dev_langsmith_api
  create_dev_redis                 = var.create_dev_redis
  create_dev_sql_credentials       = var.create_dev_sql_credentials
  create_dev_postgres_credentials  = var.create_dev_postgres_credentials
  
  # Secret values
  dev_url_alb_ecs_services  = var.dev_url_alb_ecs_services
  dev_pinecone_api          = var.dev_pinecone_api
  dev_langsmith_api         = var.dev_langsmith_api
  dev_redis                 = var.dev_redis
  dev_sql_username          = var.dev_sql_username
  dev_sql_password          = var.dev_sql_password
  dev_sql_host              = var.dev_sql_host
  dev_sql_port              = var.dev_sql_port
  dev_sql_dbname            = var.dev_sql_dbname
  dev_postgres_username     = var.dev_postgres_username
  dev_postgres_password     = var.dev_postgres_password
  dev_postgres_host         = var.dev_postgres_host
  dev_postgres_port         = var.dev_postgres_port
  dev_postgres_dbname       = var.dev_postgres_dbname
}

module "iam" {
  source                      = "./modules/iam"
  sso_instance_arn            = var.sso_instance_arn
  amplify_assume_role_policy  = var.amplify_assume_role_policy
  cognito_assume_role_policy  = var.cognito_assume_role_policy
  rds_assume_role_policy      = var.rds_assume_role_policy
  ecs_assume_role_policy      = var.ecs_assume_role_policy
  apigateway_assume_role_policy = var.apigateway_assume_role_policy
  bedrock_assume_role_policy  = var.bedrock_assume_role_policy
  lambda_assume_role_policy   = var.lambda_assume_role_policy
  s3_assume_role_policy       = var.s3_assume_role_policy
}

module "kms" {
  source          = "./modules/kms"
  environment     = var.environment
  rds_role_arn    = module.iam.rds_role_arn
  ecs_role_arn    = module.iam.ecs_role_arn
  lambda_role_arn = module.iam.lambda_role_arn
  s3_role_arn     = module.iam.s3_role_arn
  bedrock_role_arn = module.iam.bedrock_role_arn
}

module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "transit_gateway" {
  source      = "./modules/transit_gateway"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
}

module "ecs" {
  source         = "./modules/ecs"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id      = module.security_groups.ecs_security_group_id
  ecs_role_arn   = module.iam.ecs_role_arn
  assign_public_ip = false
}

module "rds" {
  source         = "./modules/rds"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id      = module.security_groups.rds_security_group_id
  rds_kms_key_id = module.kms.rds_key_id
}

module "bedrock" {
  source         = "./modules/bedrock"
  environment    = var.environment
  bedrock_role_arn = module.iam.bedrock_role_arn
  kms_key_id     = module.kms.bedrock_key_id
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
}

module "logging_monitoring" {
  source = "./modules/logging_monitoring"
  environment = var.environment
}

module "backup_dr" {
  source = "./modules/backup_dr"
  environment = var.environment
  rds_instance_id = module.rds.rds_instance_id
}

module "ci_cd" {
  source = "./modules/ci_cd"
  environment = var.environment
  github_repo_owner = var.github_repo_owner
  github_repo_name  = var.github_repo_name
  github_token      = var.github_token
}

module "cost_optimization" {
  source = "./modules/cost_optimization"
  environment = var.environment
  cost_allocation_tag_key = "Environment"
}

module "carbon_footprint" {
  source = "./modules/carbon_footprint"
  environment = var.environment
  region = var.aws_region
  carbon_report_recipients = var.carbon_report_recipients
}

module "ram" {
  source = "./modules/ram"
  environment = var.environment
  sharing_accounts = var.sharing_accounts
  resource_arns = var.resource_arns
  allow_external_principals = true
}

module "ssm_automation" {
  source = "./modules/ssm_automation"
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  instance_ids = []
  maintenance_window_schedule = "cron(0 0 ? * SUN *)"
}

module "waf" {
  source = "./modules/waf"
  environment = var.environment
  rate_limit = var.waf_rate_limit
  api_rate_limit = var.waf_api_rate_limit
  allowed_countries = var.allowed_countries
}

module "aws_config" {
  source                    = "./modules/aws_config"
  environment               = var.environment
  security_admin_account_id = var.security_admin_account_id
  config_role_arn           = var.config_role_arn
  kms_key_id                = module.kms.s3_key_id
}

module "azure_backend" {
  source = "./modules/azure_backend"
  environment = var.environment
  multi_cloud_enabled = false
}

# Add EventBridge module
module "eventbridge" {
  source        = "./modules/eventbridge"
  environment   = var.environment
  eventbus_name = var.eventbus_name

  event_rules = var.eventbridge_rules

  tags = {
    Environment = var.environment
    Project     = "foretale"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "deployment_sso_policy" {
  name        = "deployment_sso_policy"
  description = "Policy for SSO Permission Set management"
  policy      = file("${path.module}/deployment_sso_policy.json")
}

resource "aws_iam_user" "deployment_user" {
  name = "deployment-user" # Replace with your actual IAM username if different
}

resource "aws_iam_user_policy_attachment" "deployment_sso_policy_attachment" {
  user       = aws_iam_user.deployment_user.name
  policy_arn = aws_iam_policy.deployment_sso_policy.arn
}