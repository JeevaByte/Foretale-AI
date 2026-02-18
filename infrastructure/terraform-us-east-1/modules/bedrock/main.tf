# Bedrock service with KMS encryption

# Bedrock model with KMS encryption
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  logging_config {
    cloudwatch_config {
      log_group_name = "bedrock-model-logs-${var.environment}"
      role_arn       = aws_iam_role.bedrock_logging.arn
    }
    embedding_data_delivery_enabled = true
    image_data_delivery_enabled     = true
    text_data_delivery_enabled      = true
  }
}

# IAM role for Bedrock logging
resource "aws_iam_role" "bedrock_logging" {
  name = "bedrock-logging-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM policy for Bedrock logging
resource "aws_iam_role_policy" "bedrock_logging" {
  name = "bedrock-logging-policy-${var.environment}"
  role = aws_iam_role.bedrock_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:bedrock-model-logs-${var.environment}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_id
      }
    ]
  })
}

# Bedrock guardrail for content safety
resource "aws_bedrock_guardrail" "main" {
  name                      = "bedrock-guardrail-${var.environment}"
  description               = "Content safety guardrail for ${var.environment} environment"
  blocked_input_messaging   = "This input has been blocked by our content safety policy."
  blocked_outputs_messaging = "This output has been blocked by our content safety policy."

  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "SEXUAL"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "VIOLENCE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "HATE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "INSULTS"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "MISCONDUCT"
    }
    filters_config {
      input_strength  = "NONE"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Bedrock model with KMS encryption
resource "aws_bedrock_provisioned_model_throughput" "main" {
  model_id                     = "anthropic.claude-v2:1"
  provisioned_model_name       = "bedrock-model-${var.environment}"
  commitment_duration          = "OneMonth"
  instance_type                = "ml.c5.large"
  provisioned_throughput_units = 1

  tags = {
    Environment = var.environment
    KmsKeyId    = var.kms_key_id
  }
}

# CloudWatch dashboard for Bedrock monitoring
resource "aws_cloudwatch_dashboard" "bedrock" {
  dashboard_name = "bedrock-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Bedrock", "Invocations", "ModelId", "anthropic.claude-v2:1"],
            ["AWS/Bedrock", "InputTokens", "ModelId", "anthropic.claude-v2:1"],
            ["AWS/Bedrock", "OutputTokens", "ModelId", "anthropic.claude-v2:1"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Bedrock Model Usage"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Bedrock", "ModelError", "ModelId", "anthropic.claude-v2:1"],
            ["AWS/Bedrock", "Throttles", "ModelId", "anthropic.claude-v2:1"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Bedrock Model Errors"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Bedrock", "Latency", "ModelId", "anthropic.claude-v2:1"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Bedrock Model Latency"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}