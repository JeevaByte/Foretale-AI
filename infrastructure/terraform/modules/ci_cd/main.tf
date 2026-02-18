# CI/CD Pipeline for ECR Image Build and ECS Deployment
# Industry Best Practices: Source Control → Build → Scan → Push → Deploy → Audit

# ==========================================
# 1. SOURCE CONTROL - CodeCommit Repository
# ==========================================
resource "aws_codecommit_repository" "app_repo" {
  repository_name = "foretale-app-${var.environment}"
  description     = "ForeTale application source code repository"

  tags = {
    Name        = "foretale-app-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# 2. ECR REPOSITORY with Immutable Tags
# ==========================================
resource "aws_ecr_repository" "app" {
  name                 = "foretale-app-${var.environment}"
  image_tag_mutability = "IMMUTABLE" # Industry best practice - prevent tag overwrites

  image_scanning_configuration {
    scan_on_push = true # Automatic security scanning
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Name        = "foretale-app-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECR Lifecycle Policy - Keep last 10 images
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ==========================================
# 3. S3 BUCKET for Build Artifacts
# ==========================================
resource "aws_s3_bucket" "artifacts" {
  bucket = "foretale-codepipeline-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "foretale-codepipeline-artifacts-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==========================================
# 4. IAM ROLES for CodePipeline & CodeBuild
# ==========================================

# CodePipeline Role
resource "aws_iam_role" "codepipeline" {
  name = "foretale-codepipeline-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "foretale-codepipeline-role-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "foretale-codepipeline-policy-${var.environment}"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.artifacts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ]
        Resource = aws_codecommit_repository.app_repo.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [
          aws_codebuild_project.build.arn,
          aws_codebuild_project.security_scan.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.pipeline_notifications.arn
      }
    ]
  })
}

# CodeBuild Role
resource "aws_iam_role" "codebuild" {
  name = "foretale-codebuild-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "foretale-codebuild-role-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name = "foretale-codebuild-policy-${var.environment}"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/codebuild/foretale-*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ]
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:foretale/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource = "arn:aws:ec2:*:*:network-interface/*"
      }
    ]
  })
}

# ==========================================
# 5. CODEBUILD PROJECT - Build & Push Docker Image
# ==========================================
resource "aws_codebuild_project" "build" {
  name          = "foretale-build-${var.environment}"
  description   = "Build Docker image and push to ECR"
  build_timeout = 30
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true # Required for Docker builds
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.app.name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = [aws_security_group.codebuild.id]
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/foretale-build-${var.environment}"
      stream_name = "build-log"
    }
  }

  tags = {
    Name        = "foretale-build-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# 6. CODEBUILD PROJECT - Security Scan (Trivy)
# ==========================================
resource "aws_codebuild_project" "security_scan" {
  name          = "foretale-security-scan-${var.environment}"
  description   = "Security scan with Trivy and ECR scanning"
  build_timeout = 20
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.app.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec_scan.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/foretale-security-scan-${var.environment}"
      stream_name = "scan-log"
    }
  }

  tags = {
    Name        = "foretale-security-scan-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# 7. SNS TOPIC for Pipeline Notifications
# ==========================================
resource "aws_sns_topic" "pipeline_notifications" {
  name              = "foretale-pipeline-notifications-${var.environment}"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name        = "foretale-pipeline-notifications-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "pipeline_email" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ==========================================
# 8. CODEPIPELINE - Main Pipeline
# ==========================================
resource "aws_codepipeline" "main" {
  name     = "foretale-pipeline-${var.environment}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  # Stage 1: Source from CodeCommit
  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.app_repo.repository_name
        BranchName           = var.branch_name
        PollForSourceChanges = false # Use EventBridge instead
      }
    }
  }

  # Stage 2: Build Docker Image
  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  # Stage 3: Security Scan
  stage {
    name = "SecurityScan"

    action {
      name            = "TrivyScan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.security_scan.name
      }
    }
  }

  # Stage 4: Manual Approval (Production only)
  dynamic "stage" {
    for_each = var.environment == "prod" ? [1] : []

    content {
      name = "ManualApproval"

      action {
        name     = "ApprovalAction"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          NotificationArn = aws_sns_topic.pipeline_notifications.arn
          CustomData      = "Please review the build and security scan results before deploying to production."
        }
      }
    }
  }

  # Stage 5: Deploy to ECS
  stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName       = var.ecs_cluster_name
        ServiceName       = var.ecs_service_name
        FileName          = "imagedefinitions.json"
        DeploymentTimeout = 15
      }
    }
  }

  tags = {
    Name        = "foretale-pipeline-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# 9. EVENTBRIDGE RULE - Trigger on Code Commit
# ==========================================
resource "aws_cloudwatch_event_rule" "codecommit_trigger" {
  name        = "foretale-codecommit-trigger-${var.environment}"
  description = "Trigger CodePipeline on CodeCommit push to ${var.branch_name}"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.app_repo.arn]
    detail = {
      event         = ["referenceCreated", "referenceUpdated"]
      referenceType = ["branch"]
      referenceName = [var.branch_name]
    }
  })

  tags = {
    Name        = "foretale-codecommit-trigger-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule      = aws_cloudwatch_event_rule.codecommit_trigger.name
  target_id = "TriggerCodePipeline"
  arn       = aws_codepipeline.main.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

# EventBridge IAM Role
resource "aws_iam_role" "eventbridge" {
  name = "foretale-eventbridge-codepipeline-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge" {
  name = "foretale-eventbridge-policy-${var.environment}"
  role = aws_iam_role.eventbridge.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "codepipeline:StartPipelineExecution"
        Resource = aws_codepipeline.main.arn
      }
    ]
  })
}

# ==========================================
# 10. SECURITY GROUP for CodeBuild
# ==========================================
resource "aws_security_group" "codebuild" {
  name        = "foretale-codebuild-sg-${var.environment}"
  description = "Security group for CodeBuild projects"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic for Docker pulls and ECR push"
  }

  tags = {
    Name        = "foretale-codebuild-sg-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# 11. CLOUDWATCH LOG GROUPS
# ==========================================
resource "aws_cloudwatch_log_group" "build" {
  name              = "/aws/codebuild/foretale-build-${var.environment}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "foretale-build-logs-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "security_scan" {
  name              = "/aws/codebuild/foretale-security-scan-${var.environment}"
  retention_in_days = 90 # Keep security scan logs longer
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "foretale-security-scan-logs-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# 12. AUDIT LOGGING - CloudTrail for CI/CD Events
# ==========================================
resource "aws_cloudwatch_log_group" "pipeline_audit" {
  name              = "/aws/codepipeline/foretale-audit-${var.environment}"
  retention_in_days = 365 # Keep audit logs for 1 year
  kms_key_id        = var.kms_key_arn

  tags = {
    Name        = "foretale-pipeline-audit-${var.environment}"
    Environment = var.environment
    Compliance  = "AuditLog"
  }
}

# ==========================================
# Data Sources
# ==========================================
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
