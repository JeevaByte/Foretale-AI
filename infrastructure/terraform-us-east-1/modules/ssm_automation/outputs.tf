output "patch_document_arn" {
  description = "ARN of the patch instances SSM document"
  value       = aws_ssm_document.patch_instances.arn
}

output "ami_document_arn" {
  description = "ARN of the create AMI SSM document"
  value       = aws_ssm_document.create_ami.arn
}

output "audit_document_arn" {
  description = "ARN of the security group audit SSM document"
  value       = aws_ssm_document.audit_security_groups.arn
}

output "maintenance_window_id" {
  description = "ID of the maintenance window"
  value       = aws_ssm_maintenance_window.main.id
}

output "parameter_arn" {
  description = "ARN of the environment configuration parameter"
  value       = aws_ssm_parameter.environment_config.arn
}