################################################################################
# Auto Scaling Module - Outputs
################################################################################

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.ai_servers.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.ai_servers.arn
}

output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.ai_servers.id
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.ai_servers.id
}

output "launch_template_latest_version" {
  description = "Launch template latest version number"
  value       = aws_launch_template.ai_servers.latest_version
}

output "scale_up_policy_arn" {
  description = "Scale up policy ARN"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  description = "Scale down policy ARN"
  value       = aws_autoscaling_policy.scale_down.arn
}

output "cpu_scaling_policy_arn" {
  description = "CPU target tracking policy ARN"
  value       = aws_autoscaling_policy.cpu_scaling.arn
}

output "alb_request_scaling_policy_arn" {
  description = "ALB request count target tracking policy ARN"
  value       = aws_autoscaling_policy.alb_request_scaling.arn
}

output "autoscaling_summary" {
  description = "Summary of auto scaling configuration"
  value = {
    min_size      = aws_autoscaling_group.ai_servers.min_size
    max_size      = aws_autoscaling_group.ai_servers.max_size
    desired_size  = aws_autoscaling_group.ai_servers.desired_capacity
    instance_type = "t3.medium"
    scaling_policies = [
      "cpu_target_tracking",
      "alb_request_count_tracking"
    ]
  }
}
