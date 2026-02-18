################################################################################
# ForeTale Application - us-east-1 Regional Outputs
# Only VPC, ALB, and Auto Scaling outputs (Phase 1 only)
################################################################################

################################################################################
# VPC Outputs
################################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

################################################################################
# Security Groups
################################################################################

output "ai_server_security_group_id" {
  description = "Security group ID for AI server instances"
  value       = module.security_groups.ai_server_security_group_id
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = module.security_groups.alb_security_group_id
}

################################################################################
# KAN-9: Application Load Balancer Outputs
################################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB for use with CloudWatch"
  value       = module.alb.alb_arn_suffix
}

output "ai_servers_target_group_arn" {
  description = "ARN of the AI servers target group"
  value       = module.alb.ai_servers_target_group_arn
}

output "ai_servers_target_group_arn_suffix" {
  description = "ARN suffix of the AI servers target group"
  value       = module.alb.ai_servers_target_group_arn_suffix
}

################################################################################
# KAN-9: Auto Scaling Group Outputs
################################################################################

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.autoscaling.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.autoscaling.asg_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.autoscaling.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version number of the Launch Template"
  value       = module.autoscaling.launch_template_latest_version
}

################################################################################
# Regional Deployment Summary
################################################################################

output "regional_summary_us_east_1" {
  description = "Summary of resources deployed in us-east-1"
  value = {
    region           = var.aws_region
    vpc_id           = module.vpc.vpc_id
    alb_name         = "foretale-app-alb-int"
    alb_scheme       = "internal"
    asg_name         = "foretale-app-ai-servers-asg"
    asg_desired      = var.asg_desired_size
    instance_type    = var.asg_instance_type
    ami_id           = var.ami_id
  }
}
