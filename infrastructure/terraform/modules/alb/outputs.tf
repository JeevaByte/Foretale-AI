################################################################################
# Application Load Balancer Module - Outputs
################################################################################

output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Route 53 Zone ID"
  value       = aws_lb.main.zone_id
}

output "eks_target_group_arn" {
  description = "EKS target group ARN"
  value       = aws_lb_target_group.eks_workloads.arn
}

output "ai_servers_target_group_arn" {
  description = "AI servers target group ARN"
  value       = aws_lb_target_group.ai_servers.arn
}

output "ai_servers_target_group_arn_suffix" {
  description = "AI servers target group ARN suffix"
  value       = aws_lb_target_group.ai_servers.arn_suffix
}

output "lambda_target_group_arn" {
  description = "Lambda target group ARN"
  value       = aws_lb_target_group.lambda_api.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (if configured)"
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "alb_summary" {
  description = "Summary of ALB configuration"
  value = {
    dns_name      = aws_lb.main.dns_name
    http_port     = 80
    https_enabled = var.certificate_arn != ""
    target_groups = {
      eks_workloads = aws_lb_target_group.eks_workloads.name
      lambda_api    = aws_lb_target_group.lambda_api.name
    }
  }
}
