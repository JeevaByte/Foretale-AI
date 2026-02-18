################################################################################
# Application Load Balancer Module
# KAN-9: Configure Auto Scaling and Load Balancer
################################################################################

################################################################################
# Application Load Balancer
################################################################################

resource "aws_lb" "main" {
  name               = "foretale-app-alb-int"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = "foretale-app-alb-main"
    }
  )
}

################################################################################
# Target Groups
################################################################################

# Target group for EKS/Kubernetes workloads
resource "aws_lb_target_group" "eks_workloads" {
  name        = "${var.project_name}-${var.environment}-eks-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-tg"
    }
  )
}

# Target group for EC2 Auto Scaling workloads
resource "aws_lb_target_group" "ai_servers" {
  name        = "${var.project_name}-${var.environment}-ai-https-int-tg"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    protocol            = "HTTPS"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-ai-tg"
    }
  )
}

# Target group for API Gateway Lambda
resource "aws_lb_target_group" "lambda_api" {
  name        = "${var.project_name}-${var.environment}-lambda-tg"
  vpc_id      = var.vpc_id
  target_type = "lambda"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-399"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-lambda-tg"
    }
  )
}

################################################################################
# ALB Listeners
################################################################################

# HTTP listener (redirect to HTTPS in production)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai_servers.arn
  }
}

# HTTPS listener (optional - configure if SSL certificate available)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_workloads.arn
  }
}

################################################################################
# ALB Rules for routing
################################################################################

# Route /api/* to Lambda-based API Gateway
resource "aws_lb_listener_rule" "api_gateway_route" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Route /health to health check endpoint
resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai_servers.arn
  }

  condition {
    path_pattern {
      values = ["/health", "/health/*"]
    }
  }
}

################################################################################
# CloudWatch Alarms for ALB
################################################################################

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1.0 # 1 second
  alarm_description   = "Alert when ALB target response time exceeds 1 second"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when ALB has unhealthy targets"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.eks_workloads.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_http_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-http-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when ALB receives more than 10 5xx errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}
