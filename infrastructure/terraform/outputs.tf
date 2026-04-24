################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

################################################################################
# Security Group Outputs
################################################################################

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.security_groups.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS database"
  value       = module.security_groups.rds_security_group_id
}

output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  value       = module.security_groups.lambda_security_group_id
}

output "ai_server_security_group_id" {
  description = "Security group ID for AI server (EC2/WebSocket)"
  value       = module.security_groups.ai_server_security_group_id
}

################################################################################
# IAM Role Outputs
################################################################################

output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = module.iam.ecs_task_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

output "api_gateway_cloudwatch_role_arn" {
  description = "ARN of API Gateway CloudWatch role"
  value       = module.iam.api_gateway_cloudwatch_role_arn
}

output "amplify_service_role_arn" {
  description = "ARN of Amplify service role"
  value       = module.iam.amplify_service_role_arn
}

output "ai_server_role_arn" {
  description = "ARN of AI server EC2 role"
  value       = module.iam.ai_server_role_arn
}

################################################################################
# Cognito Outputs
################################################################################

output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool (required for Phase 3 API Gateway)"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_client_id" {
  description = "ID of the Cognito User Pool Client (for Flutter app)"
  value       = module.cognito.user_pool_client_id
}

output "cognito_identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = module.cognito.identity_pool_id
}

output "cognito_hosted_ui_domain" {
  description = "Cognito Hosted UI domain (for authentication flows)"
  value       = module.cognito.user_pool_domain_fqdn
}

output "cognito_authenticated_role_arn" {
  description = "ARN of the IAM role for authenticated Cognito users"
  value       = module.cognito.authenticated_role_arn
}

output "cognito_summary" {
  description = "Summary of Cognito configuration for reference"
  value       = module.cognito.cognito_summary
}

################################################################################
# Network Information
################################################################################

output "network_info" {
  description = "Summary of network configuration"
  value = {
    vpc_id             = module.vpc.vpc_id
    vpc_cidr           = module.vpc.vpc_cidr
    availability_zones = var.availability_zones
    public_subnets     = module.vpc.public_subnet_ids
    private_subnets    = module.vpc.private_subnet_ids
    database_subnets   = module.vpc.database_subnet_ids
  }
}

################################################################################
# Phase 2: S3 Outputs
################################################################################

output "s3_vector_bucket_us_east_2_id" {
  description = "ID of the vector bucket in us-east-2"
  value       = module.s3.vector_bucket_us_east_2_id
}

output "s3_vector_bucket_us_east_2_arn" {
  description = "ARN of the vector bucket in us-east-2"
  value       = module.s3.vector_bucket_us_east_2_arn
}

################################################################################
# Phase 2: RDS Outputs
################################################################################

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = module.rds.db_instance_id
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "Name of the initial database"
  value       = module.rds.db_name
}

output "rds_credentials_secret_arn" {
  description = "ARN of Secrets Manager secret containing database credentials"
  value       = module.rds.db_credentials_secret_arn
}

output "rds_credentials_secret_name" {
  description = "Name of Secrets Manager secret containing database credentials"
  value       = module.rds.db_credentials_secret_name
}

################################################################################
# Phase 2: DynamoDB Outputs
################################################################################

output "dynamodb_sessions_table_id" {
  description = "ID of the sessions DynamoDB table"
  value       = module.dynamodb.sessions_table_id
}

output "dynamodb_sessions_table_arn" {
  description = "ARN of the sessions DynamoDB table"
  value       = module.dynamodb.sessions_table_arn
}

output "dynamodb_cache_table_id" {
  description = "ID of the cache DynamoDB table"
  value       = module.dynamodb.cache_table_id
}

output "dynamodb_ai_state_table_id" {
  description = "ID of the AI state DynamoDB table"
  value       = module.dynamodb.ai_state_table_id
}

output "dynamodb_audit_logs_table_id" {
  description = "ID of the audit logs DynamoDB table"
  value       = module.dynamodb.audit_logs_table_id
}

output "dynamodb_websocket_connections_table_id" {
  description = "ID of the WebSocket connections DynamoDB table"
  value       = module.dynamodb.websocket_connections_table_id
}

output "dynamodb_all_table_names" {
  description = "List of all DynamoDB table names"
  value       = module.dynamodb.all_table_names
}

output "dynamodb_all_table_arns" {
  description = "List of all DynamoDB table ARNs"
  value       = module.dynamodb.all_table_arns
}

################################################################################
# Phase 2: Summary
################################################################################

output "phase2_summary" {
  description = "Summary of Phase 2 deployed resources"
  value = {
    s3_buckets = {
      vector_us_east_2 = module.s3.vector_bucket_us_east_2_id
    }
    rds = {
      endpoint      = module.rds.db_instance_endpoint
      database_name = module.rds.db_name
      secret_name   = module.rds.db_credentials_secret_name
    }
    dynamodb_tables = module.dynamodb.all_table_names
  }
}

################################################################################
# Phase 3: Lambda Function Outputs
################################################################################

output "lambda_ecs_invoker_arn" {
  description = "ARN of ECS invoker Lambda function"
  value       = module.lambda.ecs_invoker_function_arn
}

output "lambda_cloudwatch_log_group" {
  description = "CloudWatch log group for Lambda functions"
  value       = module.lambda.cloudwatch_log_group_name
}

################################################################################
# Phase 3: API Gateway Outputs
################################################################################

output "api_gateway_sql_id" {
  description = "ID of the SQL REST API"
  value       = module.api_gateway_sql.api_gateway_id
}

output "api_gateway_sql_invoke_url" {
  description = "Invoke URL for the SQL REST API"
  value       = module.api_gateway_sql.api_gateway_invoke_url
}

output "api_gateway_ecs_id" {
  description = "ID of the ECS REST API"
  value       = module.api_gateway_ecs.api_gateway_id
}

output "api_gateway_ecs_invoke_url" {
  description = "Invoke URL for the ECS REST API"
  value       = module.api_gateway_ecs.api_gateway_invoke_url
}

output "api_endpoint_insert_record" {
  description = "Full endpoint URL for insert_record"
  value       = "${module.api_gateway_sql.api_gateway_invoke_url}/insert_record"
}

output "api_endpoint_update_record" {
  description = "Full endpoint URL for update_record"
  value       = "${module.api_gateway_sql.api_gateway_invoke_url}/update_record"
}

output "api_endpoint_delete_record" {
  description = "Full endpoint URL for delete_record"
  value       = "${module.api_gateway_sql.api_gateway_invoke_url}/delete_record"
}

output "api_endpoint_read_record" {
  description = "Full endpoint URL for read_record"
  value       = "${module.api_gateway_sql.api_gateway_invoke_url}/read_record"
}

output "api_endpoint_read_json_record" {
  description = "Full endpoint URL for read_json_record"
  value       = "${module.api_gateway_sql.api_gateway_invoke_url}/read_json_record"
}

output "api_endpoint_ecs_invoker" {
  description = "Full endpoint URL for ecs_invoker_resource"
  value       = "${module.api_gateway_ecs.api_gateway_invoke_url}/ecs_invoker_resource"
}

################################################################################
# Phase 3: EKS Cluster Outputs
################################################################################

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.node_group_id
}

output "eks_node_group_security_group_id" {
  description = "Security group ID for EKS worker nodes"
  value       = module.eks.node_group_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

output "eks_pod_execution_role_arn" {
  description = "ARN of the pod execution role for IRSA"
  value       = module.eks.pod_execution_role_arn
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded certificate for EKS cluster"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

################################################################################
# Phase 3: Summary
################################################################################

output "phase3_summary" {
  description = "Summary of Phase 3 deployed resources"
  value = {
    api_gateways = {
      sql = {
        api_id     = module.api_gateway_sql.api_gateway_id
        invoke_url = module.api_gateway_sql.api_gateway_invoke_url
        endpoints = {
          insert_record    = "${module.api_gateway_sql.api_gateway_invoke_url}/insert_record"
          update_record    = "${module.api_gateway_sql.api_gateway_invoke_url}/update_record"
          delete_record    = "${module.api_gateway_sql.api_gateway_invoke_url}/delete_record"
          read_record      = "${module.api_gateway_sql.api_gateway_invoke_url}/read_record"
          read_json_record = "${module.api_gateway_sql.api_gateway_invoke_url}/read_json_record"
        }
      }
      ecs = {
        api_id     = module.api_gateway_ecs.api_gateway_id
        invoke_url = module.api_gateway_ecs.api_gateway_invoke_url
        endpoints = {
          ecs_invoker = "${module.api_gateway_ecs.api_gateway_invoke_url}/ecs_invoker_resource"
          get_status  = "${module.api_gateway_ecs.api_gateway_invoke_url}/get_ecs_status"
        }
      }
    }
    eks_cluster = {
      cluster_name = module.eks.cluster_name
      endpoint     = module.eks.cluster_endpoint
      version      = module.eks.cluster_version
      oidc_arn     = module.eks.oidc_provider_arn
    }
    lambda_functions = [
      module.lambda.calling_sql_procedure_function_name,
      module.lambda.ecs_invoker_function_name
    ]
  }
}

################################################################################
# KAN-9: ALB and Auto Scaling Outputs
################################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (for Route 53)"
  value       = module.alb.alb_zone_id
}

output "eks_target_group_arn" {
  description = "ARN of the EKS target group"
  value       = module.alb.eks_target_group_arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.autoscaling.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.autoscaling.asg_arn
}

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = module.autoscaling.launch_template_id
}

output "kan9_summary" {
  description = "Summary of KAN-9 (ALB and Auto Scaling) resources"
  value = {
    load_balancer = {
      dns_name = module.alb.alb_dns_name
      arn      = module.alb.alb_arn
    }
    auto_scaling = {
      asg_name      = module.autoscaling.asg_name
      min_size      = var.asg_min_size
      max_size      = var.asg_max_size
      desired_size  = var.asg_desired_size
      instance_type = var.asg_instance_type
      scaling_policies = [
        "cpu_target_tracking",
        "alb_request_count_tracking"
      ]
    }
  }
}

