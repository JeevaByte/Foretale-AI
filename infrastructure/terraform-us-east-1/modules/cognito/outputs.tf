################################################################################
# Cognito Module Outputs
################################################################################

# User Pool Outputs
output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "user_pool_name" {
  description = "Name of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.name
}

# User Pool Client Outputs
output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client (Flutter App)"
  value       = aws_cognito_user_pool_client.flutter_app.id
}

output "user_pool_client_name" {
  description = "Name of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.flutter_app.name
}

# User Pool Domain Outputs
output "user_pool_domain_name" {
  description = "Domain name of the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.main.domain
}

output "user_pool_domain_fqdn" {
  description = "Fully qualified domain name of the Cognito hosted UI"
  value       = "${aws_cognito_user_pool_domain.main.domain}.auth.us-east-2.amazonaws.com"
}

# Identity Pool Outputs
output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.id
}

output "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.identity_pool_name
}

# IAM Role Outputs
output "authenticated_role_arn" {
  description = "ARN of the IAM role for authenticated Cognito users"
  value       = aws_iam_role.cognito_authenticated_role.arn
}

output "authenticated_role_name" {
  description = "Name of the IAM role for authenticated Cognito users"
  value       = aws_iam_role.cognito_authenticated_role.name
}

# Summary Output
output "cognito_summary" {
  description = "Summary of Cognito configuration for Phase 3"
  value = {
    user_pool_arn       = aws_cognito_user_pool.main.arn
    user_pool_id        = aws_cognito_user_pool.main.id
    user_pool_client_id = aws_cognito_user_pool_client.flutter_app.id
    identity_pool_id    = aws_cognito_identity_pool.main.id
    hosted_ui_domain    = "${aws_cognito_user_pool_domain.main.domain}.auth.us-east-2.amazonaws.com"
  }
}
