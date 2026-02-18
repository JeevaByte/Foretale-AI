variable "lambda_zip_path" {
  description = "Path to Lambda deployment package zip file"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "security_admin_account_id" {
  description = "Security admin account ID"
  type        = string
}

variable "config_role_arn" {
  description = "Config role ARN"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "client_name" {
  description = "Client name"
  type        = string
  default     = "client1"
}

variable "client_dev_email" {
  description = "Client development email"
  type        = string
  default     = "client1-dev@example.com"
}

variable "client_uat_email" {
  description = "Client UAT email"
  type        = string
  default     = "client1-uat@example.com"
}

variable "client_prod_email" {
  description = "Client production email"
  type        = string
  default     = "client1-prod@example.com"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "cost_center" {
  description = "Cost center code"
  type        = string
  default     = "12345"
}

variable "sustainability" {
  description = "Sustainability level"
  type        = string
  default     = "Medium"
}

variable "kms_policy" {
  description = "KMS policy JSON"
  type        = string
  default     = "{}"
}

variable "rds_rotation_lambda_arn" {
  description = "RDS rotation Lambda ARN"
  type        = string
  default     = "arn:aws:lambda:eu-west-2:442426872653:function:rds-rotation"
}

variable "sso_instance_arn" {
  description = "SSO instance ARN"
  type        = string
  default     = "arn:aws:sso:::instance/ssoins-1234567890abcdef"
}

variable "amplify_assume_role_policy" {
  description = "Amplify assume role policy"
  type        = string
  default     = "{}"
}

variable "cognito_assume_role_policy" {
  description = "Cognito assume role policy"
  type        = string
  default     = "{}"
}

variable "rds_assume_role_policy" {
  description = "RDS assume role policy"
  type        = string
  default     = "{}"
}

variable "ecs_assume_role_policy" {
  description = "ECS assume role policy"
  type        = string
  default     = "{}"
}

variable "apigateway_assume_role_policy" {
  description = "API Gateway assume role policy"
  type        = string
  default     = "{}"
}

variable "bedrock_assume_role_policy" {
  description = "Bedrock assume role policy"
  type        = string
  default     = "{}"
}

variable "lambda_assume_role_policy" {
  description = "Lambda assume role policy"
  type        = string
  default     = "{}"
}

variable "s3_assume_role_policy" {
  description = "S3 assume role policy"
  type        = string
  default     = "{}"
}

variable "github_repo_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "your-org"
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "flutter_aws_deployment"
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  default     = "your-github-token"
}

variable "carbon_report_recipients" {
  description = "Carbon report recipients"
  type        = list(string)
  default     = ["sustainability@example.com"]
}

variable "sharing_accounts" {
  description = "Accounts to share resources with"
  type        = list(string)
  default     = []
}

variable "resource_arns" {
  description = "Resource ARNs for Resource Access Manager"
  type        = list(string)
  default     = []
}

variable "waf_rate_limit" {
  description = "WAF rate limit"
  type        = number
  default     = 2000
}

variable "waf_api_rate_limit" {
  description = "WAF API rate limit"
  type        = number
  default     = 1000
}

variable "allowed_countries" {
  description = "Allowed countries for WAF"
  type        = list(string)
  default     = ["US", "GB", "DE", "FR", "CA"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "eventbus_name" {
  description = "EventBridge bus name"
  type        = string
  default     = "foretale-event-bus"
}

variable "eventbridge_rules" {
  description = "EventBridge rules configuration"
  type = map(object({
    description     = string
    event_pattern   = string
    enabled         = bool
    targets = map(object({
      name                   = string
      arn                    = string
      role_arn               = string
      input                  = optional(string)
      input_path             = optional(string)
      input_transformer      = optional(map(string))
      retry_policy           = optional(map(number))
      dead_letter_config_arn = optional(string)
    }))
  }))
  default = {}
}

################################################################################
# Secrets Manager Variables
################################################################################

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "foretale"
}

variable "create_dev_url_alb_ecs_services" {
  description = "Create ALB ECS Services URL secret"
  type        = bool
  default     = true
}

variable "create_dev_pinecone_api" {
  description = "Create Pinecone API key secret"
  type        = bool
  default     = true
}

variable "create_dev_langsmith_api" {
  description = "Create LangSmith API key secret"
  type        = bool
  default     = true
}

variable "create_dev_redis" {
  description = "Create Redis password secret"
  type        = bool
  default     = true
}

variable "create_dev_sql_credentials" {
  description = "Create SQL Server credentials secret"
  type        = bool
  default     = true
}

variable "create_dev_postgres_credentials" {
  description = "Create PostgreSQL credentials secret"
  type        = bool
  default     = true
}

variable "dev_url_alb_ecs_services" {
  description = "ALB ECS Services URL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_pinecone_api" {
  description = "Pinecone API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_langsmith_api" {
  description = "LangSmith API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_redis" {
  description = "Redis password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_sql_username" {
  description = "SQL Server username"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_sql_password" {
  description = "SQL Server password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_sql_host" {
  description = "SQL Server host endpoint"
  type        = string
  default     = ""
}

variable "dev_sql_port" {
  description = "SQL Server port"
  type        = number
  default     = 1433
}

variable "dev_sql_dbname" {
  description = "SQL Server database instance name"
  type        = string
  default     = ""
}

variable "dev_postgres_username" {
  description = "PostgreSQL username"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dev_postgres_host" {
  description = "PostgreSQL host endpoint"
  type        = string
  default     = ""
}

variable "dev_postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "dev_postgres_dbname" {
  description = "PostgreSQL database name"
  type        = string
  default     = ""
}

# Global variables