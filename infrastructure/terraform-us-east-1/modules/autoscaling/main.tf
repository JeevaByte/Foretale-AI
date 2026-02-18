################################################################################
# Auto Scaling and Scaling Policies
# KAN-9: Configure Auto Scaling and Load Balancer
################################################################################

################################################################################
# EC2 Auto Scaling Group (for EKS node group scaling)
################################################################################

# Note: EKS node groups have their own scaling configured
# This ASG is for non-EKS EC2-based workloads if needed

resource "aws_autoscaling_group" "ai_servers" {
  name                      = "${var.app_name}-ai-servers-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.alb_target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_size

  launch_template {
    id      = aws_launch_template.ai_servers.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-ai-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Launch Template for EC2 instances
################################################################################

resource "aws_launch_template" "ai_servers" {
  name_prefix = "${var.app_name}-lt-"
  description = "Launch template for AI/ML EC2 instances"

  instance_type = var.instance_type
  image_id      = var.ami_id

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region
  }))

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.app_name}-ai-server"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "${var.app_name}-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Scaling Policies
################################################################################

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.app_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.ai_servers.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.ai_servers.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# Target Tracking Scaling Policy (CPU)
resource "aws_autoscaling_policy" "cpu_scaling" {
  name                   = "${var.app_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.ai_servers.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_utilization
  }
}

# Target Tracking Scaling Policy (ALB Request Count)
resource "aws_autoscaling_policy" "alb_request_scaling" {
  name                   = "${var.app_name}-alb-request-scaling"
  autoscaling_group_name = aws_autoscaling_group.ai_servers.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
    }
    target_value = var.alb_request_target
  }
}

################################################################################
# CloudWatch Alarms for Scaling
################################################################################

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when CPU utilization is high"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ai_servers.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.app_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Alert when CPU utilization is low"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ai_servers.name
  }

  tags = var.tags
}

################################################################################
# Data Sources
################################################################################

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
