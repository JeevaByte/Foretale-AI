################################################################################
# Cognito User Pool - ForeTale Application
################################################################################

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name                = "foretale-app-cognito-main"
  username_attributes = ["email"]

  # Password Policy
  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Email Configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # MFA Configuration
  mfa_configuration = var.enable_mfa ? "OPTIONAL" : "OFF"

  # Account Recovery Settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User Attribute Update Settings
  auto_verified_attributes = ["email"]

  # Email Verification
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "ForeTale - Email Verification Code"
    email_message        = "Your ForeTale verification code is {####}"
  }

  # Standard attributes are automatically available (email, phone_number, given_name, family_name, etc.)
  # Custom attributes can be added here if needed, but standard attributes cannot be defined in schema

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  tags = var.tags
}

################################################################################
# Cognito User Pool Client - Flutter App
################################################################################

resource "aws_cognito_user_pool_client" "flutter_app" {
  name         = "${var.project_name}-${var.environment}-flutter-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Authentication Flows - Use only modern flows (ALLOW_* format)
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  # Token Validity
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # Prevent User Existence Errors (Security Best Practice)
  prevent_user_existence_errors = "ENABLED"

  # Generate Secret (not recommended for public clients like Flutter, but can be used)
  generate_secret = false
}

################################################################################
# Cognito User Pool Domain - For Hosted UI (Optional)
################################################################################

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

################################################################################
# Cognito Identity Pool (Federated Identity) - For AWS Resource Access
################################################################################

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}_${var.environment}_identity_pool"
  allow_classic_flow               = false
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.flutter_app.id
    provider_name = aws_cognito_user_pool.main.endpoint
  }

  tags = var.tags
}

################################################################################
# IAM Role for Authenticated Users
################################################################################

resource "aws_iam_role" "cognito_authenticated_role" {
  name = "${var.project_name}-${var.environment}-cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAllValues:StringLike" = {
            "cognito-identity.amazonaws.com:sub" = "*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

################################################################################
# Cognito Identity Pool Role Attachment
################################################################################

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated = aws_iam_role.cognito_authenticated_role.arn
  }
}

################################################################################
# Data Source for AWS Account ID
################################################################################

data "aws_caller_identity" "current" {}
