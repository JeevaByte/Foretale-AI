# Terraform Outputs

# Overview
# This file defines the outputs from the Terraform deployment that can be used by other systems or for reference.

# VPC Outputs
output "vpc_id" {
  description = "ID of the main VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "IDs of the isolated subnets"
  value       = module.vpc.isolated_subnet_ids
}

## Security Outputs
output "security_groups" {
  description = "Security group IDs"
  value = {
    alb     = module.security_groups.alb_security_group_id
    ecs     = module.security_groups.ecs_security_group_id
    rds     = module.security_groups.rds_security_group_id
    lambda  = module.security_groups.lambda_security_group_id
    bedrock = module.security_groups.bedrock_security_group_id
    apigateway = module.security_groups.apigateway_security_group_id
  }
}

## IAM Outputs
output "iam_roles" {
  description = "IAM role ARNs"
  value = {
    rds        = module.iam.rds_role_arn
    ecs        = module.iam.ecs_role_arn
    bedrock    = module.iam.bedrock_role_arn
    lambda     = module.iam.lambda_role_arn
    s3         = module.iam.s3_role_arn
    amplify    = module.iam.amplify_role_arn
    cognito    = module.iam.cognito_role_arn
    apigateway = module.iam.apigateway_role_arn
  }
}

## KMS Outputs
output "kms_keys" {
  description = "KMS key IDs and ARNs"
  value = {
    rds = {
      id  = module.kms.rds_key_id
      arn = module.kms.rds_key_arn
    }
    ebs = {
      id  = module.kms.ebs_key_id
      arn = module.kms.ebs_key_arn
    }
    s3 = {
      id  = module.kms.s3_key_id
      arn = module.kms.s3_key_arn
    }
    bedrock = {
      id  = module.kms.bedrock_key_id
      arn = module.kms.bedrock_key_arn
    }
  }
}

## ECS Outputs
output "ecs_cluster" {
  description = "ECS cluster information"
  value = {
    id   = module.ecs.ecs_cluster_id
    name = module.ecs.ecs_cluster_name
  }
}

output "ecs_service" {
  description = "ECS service information"
  value = {
    id   = module.ecs.ecs_service_id
    name = module.ecs.ecs_service_name
  }
}

output "ecs_alb" {
  description = "ECS Application Load Balancer information"
  value = {
    dns_name = module.ecs.alb_dns_name
    zone_id  = module.ecs.alb_zone_id
  }
}

## RDS Outputs
output "rds_instance" {
  description = "RDS instance information"
  value = {
    id       = module.rds.rds_instance_id
    endpoint = module.rds.rds_instance_endpoint
    port     = module.rds.rds_instance_port
  }
}

## Bedrock Outputs
output "bedrock" {
  description = "Bedrock service information"
  value = {
    model_arn      = module.bedrock.bedrock_model_arn
    guardrail_arn  = module.bedrock.bedrock_guardrail_arn
    logging_role_arn = module.bedrock.bedrock_logging_role_arn
  }
}

## Monitoring Outputs
output "cloudwatch_dashboards" {
  description = "CloudWatch dashboard ARNs"
  value = {
    kms        = module.kms.kms_dashboard_arn
    nat_gateway = module.vpc.nat_gateway_dashboard_name
    rds        = module.rds.rds_dashboard_arn
    config      = module.aws_config.config_dashboard_arn
    logging     = module.logging_monitoring.logging_dashboard_arn
    sustainability = module.carbon_footprint.dashboard_arn
    sustainability_metrics = module.carbon_footprint.sustainability_metrics_dashboard_arn
  }
}

## Transit Gateway Outputs
output "transit_gateway" {
  description = "Transit Gateway information"
  value = {
    id          = module.transit_gateway.transit_gateway_id
    attachment_id = module.transit_gateway.transit_gateway_attachment_id
    route_table_id = module.transit_gateway.transit_gateway_route_table_id
  }
}

## SSM Automation Outputs
output "ssm_automation" {
  description = "SSM automation information"
  value = {
    patch_document_arn    = module.ssm_automation.patch_document_arn
    ami_document_arn      = module.ssm_automation.ami_document_arn
    audit_document_arn    = module.ssm_automation.audit_document_arn
    maintenance_window_id = module.ssm_automation.maintenance_window_id
    parameter_arn         = module.ssm_automation.parameter_arn
  }
}

## Resource Access Manager Outputs
output "ram" {
  description = "Resource Access Manager information"
  value = {
    resource_share_arn = module.ram.resource_share_arn
    resource_share_id  = module.ram.resource_share_id
  }
}

## Cost Optimization Outputs
output "cost_optimization" {
  description = "Cost optimization information"
  value = {
    anomaly_monitor_arn = module.cost_optimization.anomaly_monitor_arn
    budget_names        = module.cost_optimization.budget_names
    cost_category_arn   = module.cost_optimization.cost_category_arn
  }
}