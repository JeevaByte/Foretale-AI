# Milestone 1: AWS Organizations, Account Vending, Security Stack

// Removed: resource "aws_organizations_organization" "org" {}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = var.organization_root_id
}
resource "aws_organizations_organizational_unit" "shared_services" {
  name      = "Shared Services"
  parent_id = var.organization_root_id
}
resource "aws_organizations_organizational_unit" "clients" {
  name      = "Clients"
  parent_id = var.organization_root_id
}
resource "aws_organizations_organizational_unit" "dev" {
  name      = "DEV"
  parent_id = aws_organizations_organizational_unit.clients.id
}
resource "aws_organizations_organizational_unit" "uat" {
  name      = "UAT"
  parent_id = aws_organizations_organizational_unit.clients.id
}
resource "aws_organizations_organizational_unit" "prod" {
  name      = "PROD"
  parent_id = aws_organizations_organizational_unit.clients.id
}

resource "aws_organizations_policy" "mfa_enforce" {
  name    = "EnforceMFA"
  content = file("${path.module}/scp_mfa.json")
  type    = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "mfa_enforce_clients" {
  policy_id = aws_organizations_policy.mfa_enforce.id
  target_id = aws_organizations_organizational_unit.clients.id
}
resource "aws_organizations_policy" "region_restrict" {
  name    = "RegionRestrict"
  content = file("${path.module}/scp_region.json")
  type    = "SERVICE_CONTROL_POLICY"
}
resource "aws_organizations_policy_attachment" "region_restrict_clients" {
  policy_id = aws_organizations_policy.region_restrict.id
  target_id = aws_organizations_organizational_unit.clients.id
}
resource "aws_organizations_policy" "termination_prevent" {
  name    = "TerminationPrevent"
  content = file("${path.module}/scp_termination.json")
  type    = "SERVICE_CONTROL_POLICY"
}

# Automated Account Creation Lambda
resource "aws_lambda_function" "account_vending" {
  function_name = "account-vending-${var.environment}"
  role          = aws_iam_role.account_vending_lambda.arn
  handler       = "account_vending.handler"
  runtime       = "python3.9"
  filename      = var.scp_validation_lambda_zip_path
  timeout       = 900 # 15 minutes for account creation

  environment {
    variables = {
      ENVIRONMENT           = var.environment
      ORG_ROOT_ID           = var.organization_root_id
      CLIENTS_OU_ID         = aws_organizations_organizational_unit.clients.id
      DEV_OU_ID             = aws_organizations_organizational_unit.dev.id
      UAT_OU_ID             = aws_organizations_organizational_unit.uat.id
      PROD_OU_ID            = aws_organizations_organizational_unit.prod.id
      MFA_POLICY_ID         = aws_organizations_policy.mfa_enforce.id
      REGION_POLICY_ID      = aws_organizations_policy.region_restrict.id
      TERMINATION_POLICY_ID = aws_organizations_policy.termination_prevent.id
    }
  }

  tags = {
    Environment = var.environment
    Purpose     = "AccountVending"
  }
}

# IAM Role for Account Vending Lambda
resource "aws_iam_role" "account_vending_lambda" {
  name = "account-vending-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Policy for Account Vending Lambda
resource "aws_iam_role_policy" "account_vending_lambda" {
  name = "account-vending-lambda-policy-${var.environment}"
  role = aws_iam_role.account_vending_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "organizations:CreateAccount",
          "organizations:DescribeCreateAccountStatus",
          "organizations:MoveAccount",
          "organizations:AttachPolicy",
          "organizations:DetachPolicy",
          "organizations:ListAccounts",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:ListAccountsForParent",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sts:AssumeRole",
          "ssm:PutParameter",
          "ssm:GetParameter",
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# Step Functions State Machine for Account Provisioning Workflow
resource "aws_sfn_state_machine" "account_provisioning" {
  name     = "account-provisioning-${var.environment}"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Account provisioning workflow"
    StartAt = "ValidateRequest"
    States = {
      ValidateRequest = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "CreateAccount"
        Parameters = {
          "action"    = "validate"
          "payload.$" = "$"
        }
      }
      CreateAccount = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "WaitForAccountCreation"
        Parameters = {
          "action"    = "create"
          "payload.$" = "$"
        }
      }
      WaitForAccountCreation = {
        Type    = "Wait"
        Seconds = 30
        Next    = "CheckAccountStatus"
      }
      CheckAccountStatus = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "IsAccountReady"
        Parameters = {
          "action"    = "check_status"
          "payload.$" = "$"
        }
      }
      IsAccountReady = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.status"
            StringEquals = "SUCCEEDED"
            Next         = "MoveToOU"
          },
          {
            Variable     = "$.status"
            StringEquals = "FAILED"
            Next         = "AccountCreationFailed"
          }
        ]
        Default = "WaitForAccountCreation"
      }
      MoveToOU = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "AttachPolicies"
        Parameters = {
          "action"    = "move_to_ou"
          "payload.$" = "$"
        }
      }
      AttachPolicies = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "SetupBaseline"
        Parameters = {
          "action"    = "attach_policies"
          "payload.$" = "$"
        }
      }
      SetupBaseline = {
        Type     = "Task"
        Resource = aws_lambda_function.account_vending.arn
        Next     = "AccountProvisioningComplete"
        Parameters = {
          "action"    = "setup_baseline"
          "payload.$" = "$"
        }
      }
      AccountProvisioningComplete = {
        Type = "Succeed"
      }
      AccountCreationFailed = {
        Type  = "Fail"
        Cause = "Account creation failed"
      }
    }
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "step-functions-account-provisioning-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Policy for Step Functions
resource "aws_iam_role_policy" "step_functions" {
  name = "step-functions-policy-${var.environment}"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.account_vending.arn
      }
    ]
  })
}

# API Gateway for Account Vending
resource "aws_api_gateway_rest_api" "account_vending" {
  name        = "account-vending-api-${var.environment}"
  description = "API for automated account provisioning"

  tags = {
    Environment = var.environment
  }
}

resource "aws_api_gateway_resource" "account_vending" {
  rest_api_id = aws_api_gateway_rest_api.account_vending.id
  parent_id   = aws_api_gateway_rest_api.account_vending.root_resource_id
  path_part   = "provision-account"
}

resource "aws_api_gateway_method" "account_vending" {
  rest_api_id   = aws_api_gateway_rest_api.account_vending.id
  resource_id   = aws_api_gateway_resource.account_vending.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "account_vending" {
  rest_api_id = aws_api_gateway_rest_api.account_vending.id
  resource_id = aws_api_gateway_resource.account_vending.id
  http_method = aws_api_gateway_method.account_vending.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_sfn_state_machine.account_provisioning.arn
  credentials             = aws_iam_role.api_gateway.arn
}

# IAM Role for API Gateway
resource "aws_iam_role" "api_gateway" {
  name = "api-gateway-account-vending-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Policy for API Gateway
resource "aws_iam_role_policy" "api_gateway" {
  name = "api-gateway-policy-${var.environment}"
  role = aws_iam_role.api_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = aws_sfn_state_machine.account_provisioning.arn
      }
    ]
  })
}
resource "aws_organizations_policy_attachment" "termination_prevent_clients" {
  policy_id = aws_organizations_policy.termination_prevent.id
  target_id = aws_organizations_organizational_unit.clients.id
}

resource "aws_organizations_policy" "tag_policy" {
  name    = "TagPolicy"
  content = file("${path.module}/tag_policy.json")
}
resource "aws_organizations_policy_attachment" "tag_policy_clients" {
  policy_id = aws_organizations_policy.tag_policy.id
  target_id = aws_organizations_organizational_unit.clients.id
}
resource "aws_organizations_account" "client_dev" {
  name      = var.client_name
  email     = var.client_dev_email
  parent_id = aws_organizations_organizational_unit.dev.id
}
resource "aws_organizations_account" "client_uat" {
  name      = var.client_name
  email     = var.client_uat_email
  parent_id = aws_organizations_organizational_unit.uat.id
}

resource "aws_organizations_account" "client_prod" {
  name      = var.client_name
  email     = var.client_prod_email
  parent_id = aws_organizations_organizational_unit.prod.id
}

# Baseline security stack
module "cloudtrail" {
  source      = "../logging_monitoring"
  environment = var.environment
}

module "securityhub" {
  source                    = "../security"
  security_admin_account_id = var.security_admin_account_id
  config_role_arn           = var.config_role_arn
  client_dev_email          = var.client_dev_email
  environment               = var.environment
}

module "vpc_dev" {
  source               = "../vpc"
  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  environment          = "dev"
  cost_center          = var.cost_center
  sustainability       = var.sustainability
  naming_prefix        = "foretale-app"
}

module "vpc_uat" {
  source               = "../vpc"
  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  environment          = "uat"
  cost_center          = var.cost_center
  sustainability       = var.sustainability
  naming_prefix        = "foretale-app"
}

module "vpc_prod" {
  source               = "../vpc"
  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  environment          = "prod"
  cost_center          = var.cost_center
  sustainability       = var.sustainability
  naming_prefix        = "foretale-app"
}
