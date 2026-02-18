################################################################################
# AWS Amplify App - us-east-2
################################################################################

# NOTE: Since repository is client-owned, authentication requires:
# Option 1: GitHub Personal Access Token from client
# Option 2: GitHub Deploy Key (SSH) - request from client
# Option 3: OAuth through AWS Amplify Console (interactive, no Terraform variable needed)

variable "github_token" {
  description = "GitHub personal access token for repository access (from client)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "amplify_repository" {
  description = "GitHub repository URL for Amplify app"
  type        = string
  default     = "https://github.com/bharath-arcot-babu/foretale_application"
}

# Amplify App for us-east-2
resource "aws_amplify_app" "foretaleapplication_us_east_2" {
  count = var.github_token != "" ? 1 : 0

  name                 = "foretaleapplication"
  repository           = var.amplify_repository
  access_token         = var.github_token
  platform             = "WEB"
  iam_service_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/amplify-service-role"

  # Environment variables matching us-east-1 configuration
  environment_variables = {
    AI_ASSISTANT_HOST = "faretale-public-lb-911837398.us-east-1.elb.amazonaws.com"
    _LIVE_UPDATES = jsonencode([
      {
        name    = "Amplify CLI"
        pkg     = "@aws-amplify/cli"
        type    = "npm"
        version = "latest"
      }
    ])
  }

  # Build specification for Flutter web build
  build_spec = base64encode(<<-EOT
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - echo "Installing Flutter SDK"
        - git clone https://github.com/flutter/flutter.git -b stable --depth 1
        - export PATH="$PATH:$(pwd)/flutter/bin"
        - flutter config --no-analytics
        - flutter doctor -v
        - flutter pub get

    build:
      commands:
        - echo "Building Flutter Web (JS-only, CanvasKit)"
        - flutter clean
        - flutter build web --release

  artifacts:
    baseDirectory: build/web
    files:
      - '**/*'

  cache:
    paths:
      - ~/.pub-cache
EOT
  )

  # Custom rules for SPA routing
  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "404-200"
  }

  # Cache configuration
  cache_config {
    type = "AMPLIFY_MANAGED_NO_COOKIES"
  }

  # Disable auto build/deletion
  enable_auto_branch_creation = false
  enable_branch_auto_deletion = false
  enable_basic_auth           = false

  tags = {
    Name = "foretaleapplication-us-east-2"
  }
}

# Amplify Branch Configuration - main branch
resource "aws_amplify_branch" "main_us_east_2" {
  count = var.github_token != "" ? 1 : 0

  app_id      = aws_amplify_app.foretaleapplication_us_east_2[0].id
  branch_name = "main"

  enable_auto_build = true
  stage             = "PRODUCTION"
  framework         = "Web"

  environment_variables = {
    AMPLIFY_BACKEND_APP_ID = aws_amplify_app.foretaleapplication_us_east_2[0].id
    USER_BRANCH            = "dev"
  }

  ttl = "5"

  enable_pull_request_preview = false
  enable_notification         = false

  depends_on = [aws_amplify_app.foretaleapplication_us_east_2]
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Outputs
output "amplify_app_id_us_east_2" {
  description = "Amplify App ID for us-east-2"
  value       = try(aws_amplify_app.foretaleapplication_us_east_2[0].id, "")
}

output "amplify_app_arn_us_east_2" {
  description = "Amplify App ARN for us-east-2"
  value       = try(aws_amplify_app.foretaleapplication_us_east_2[0].arn, "")
}

output "amplify_default_domain_us_east_2" {
  description = "Amplify default domain for us-east-2"
  value       = try(aws_amplify_app.foretaleapplication_us_east_2[0].default_domain, "")
}

output "amplify_repository_url" {
  description = "Repository URL configured for Amplify"
  value       = try(aws_amplify_app.foretaleapplication_us_east_2[0].repository, "")
}
