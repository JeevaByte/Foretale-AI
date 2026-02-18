# SSM Automation documents and configurations

# Document for EC2 instance patching
resource "aws_ssm_document" "patch_instances" {
  name          = "patch-ec2-instances-${var.environment}"
  document_type = "Automation"

  content = jsonencode({
    schemaVersion = "0.3"
    description   = "Patch EC2 instances in ${var.environment} environment"
    parameters = {
      InstanceIds = {
        type        = "StringList"
        description = "List of instance IDs to patch"
        default     = var.instance_ids
      }
    }
    mainSteps = [
      {
        name   = "patchInstances"
        action = "aws:runCommand"
        inputs = {
          DocumentName = "AWS-RunPatchBaseline"
          InstanceIds  = "{{ InstanceIds }}"
          Parameters = {
            Operation = "Install"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Document for AMI creation
resource "aws_ssm_document" "create_ami" {
  name          = "create-ami-${var.environment}"
  document_type = "Automation"

  content = jsonencode({
    schemaVersion = "0.3"
    description   = "Create AMI from EC2 instance in ${var.environment} environment"
    parameters = {
      InstanceId = {
        type        = "String"
        description = "Instance ID to create AMI from"
      }
      AmiName = {
        type        = "String"
        description = "Name for the AMI"
        default     = "ami-${var.environment}-{{global:DATE}}"
      }
    }
    mainSteps = [
      {
        name   = "createImage"
        action = "aws:createImage"
        inputs = {
          InstanceId = "{{ InstanceId }}"
          ImageName  = "{{ AmiName }}"
          NoReboot   = true
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Document for security group audit
resource "aws_ssm_document" "audit_security_groups" {
  name          = "audit-security-groups-${var.environment}"
  document_type = "Automation"

  content = jsonencode({
    schemaVersion = "0.3"
    description   = "Audit security groups in ${var.environment} environment"
    parameters = {
      VpcId = {
        type        = "String"
        description = "VPC ID to audit"
        default     = var.vpc_id
      }
    }
    mainSteps = [
      {
        name   = "describeSecurityGroups"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "ec2"
          Api     = "DescribeSecurityGroups"
          Filters = [
            {
              Name   = "vpc-id"
              Values = ["{{ VpcId }}"]
            }
          ]
        }
        outputs = [
          {
            Name     = "SecurityGroups"
            Selector = "$.SecurityGroups"
            Type     = "StringMap"
          }
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Maintenance window for automation
resource "aws_ssm_maintenance_window" "main" {
  name                       = "maintenance-window-${var.environment}"
  schedule                   = var.maintenance_window_schedule
  duration                   = 2 # hours
  cutoff                     = 1 # hour
  allow_unassociated_targets = false

  tags = {
    Environment = var.environment
  }
}

# Maintenance window target for EC2 instances
resource "aws_ssm_maintenance_window_target" "ec2_instances" {
  window_id     = aws_ssm_maintenance_window.main.id
  resource_type = "INSTANCE"
  targets {
    key    = "tag:Environment"
    values = [var.environment]
  }

  tags = {
    Environment = var.environment
  }
}

# Maintenance window task for patching
resource "aws_ssm_maintenance_window_task" "patch_instances" {
  window_id       = aws_ssm_maintenance_window.main.id
  task_type       = "AUTOMATION"
  task_arn        = aws_ssm_document.patch_instances.arn
  priority        = 1
  max_concurrency = "10"
  max_errors      = "5"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.ec2_instances.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"
      parameter {
        name   = "InstanceIds"
        values = var.instance_ids
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# SSM parameter for environment configuration
resource "aws_ssm_parameter" "environment_config" {
  name = "/${var.environment}/config"
  type = "String"
  value = jsonencode({
    environment = var.environment
    vpc_id      = var.vpc_id
    region      = data.aws_region.current.name
  })

  tags = {
    Environment = var.environment
  }
}

# Get current region
data "aws_region" "current" {}