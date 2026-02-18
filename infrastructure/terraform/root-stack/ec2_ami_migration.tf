# Terraform Configuration: EC2 AMI Migration & Load Balancer Setup
# This code creates an AMI from us-east-1 instance and deploys it in us-east-2 with ALB

# ============================================================================
# VARIABLES
# ============================================================================

variable "source_instance_id" {
  description = "EC2 Instance ID to create AMI from (us-east-1)"
  type        = string
  default     = "i-0f27e2388c5f34c46"  # Replace with your instance ID
}

variable "source_region" {
  description = "Source region for AMI"
  type        = string
  default     = "us-east-1"
}

variable "target_region" {
  description = "Target region for EC2 instance deployment"
  type        = string
  default     = "us-east-2"
}

variable "instance_count" {
  description = "Number of EC2 instances to launch in target region"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.xlarge"
}

variable "app_name" {
  description = "Application name for tagging"
  type        = string
  default     = "foretale-app"
}

# ============================================================================
# PROVIDERS
# ============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "source"
  region = var.source_region
}

provider "aws" {
  alias  = "target"
  region = var.target_region
}

# ============================================================================
# STEP 1: CREATE AMI FROM SOURCE INSTANCE (us-east-1)
# ============================================================================

resource "aws_ami_from_instance" "source_ami" {
  provider            = aws.source
  name                = "${var.app_name}-ami-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  description         = "AMI created from ${var.source_instance_id} in ${var.source_region}"
  source_instance_id  = var.source_instance_id
  snapshot_without_reboot = false  # Ensures data consistency

  tags = {
    Name        = "${var.app_name}-ami"
    Environment = var.environment
    SourceRegion = var.source_region
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [aws_ami_from_instance.source_ami]
}

# ============================================================================
# STEP 2: COPY AMI TO TARGET REGION (us-east-2)
# ============================================================================

resource "aws_ami_copy" "target_ami" {
  provider           = aws.target
  name               = "${var.app_name}-ami-us-east-2"
  description        = "Copy of AMI from ${var.source_region}"
  source_ami_id      = aws_ami_from_instance.source_ami.id
  source_ami_region  = var.source_region
  encrypted          = true

  tags = {
    Name        = "${var.app_name}-ami-us-east-2"
    Environment = var.environment
    SourceRegion = var.source_region
    CopiedDate   = formatdate("YYYY-MM-DD", timestamp())
  }

  depends_on = [aws_ami_from_instance.source_ami]
}

# ============================================================================
# STEP 3: CREATE VPC AND NETWORKING (us-east-2)
# ============================================================================

resource "aws_vpc" "main" {
  provider           = aws.target
  cidr_block         = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  provider = aws.target
  vpc_id   = aws_vpc.main.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_1" {
  provider                = aws.target
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_2" {
  provider                = aws.target
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-2"
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
  provider = aws.target
  state    = "available"
}

resource "aws_route_table" "public" {
  provider = aws.target
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.app_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_1" {
  provider       = aws.target
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  provider       = aws.target
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# STEP 4: SECURITY GROUPS
# ============================================================================

resource "aws_security_group" "alb" {
  provider    = aws.target
  name        = "${var.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "ec2" {
  provider    = aws.target
  name        = "${var.app_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-ec2-sg"
    Environment = var.environment
  }
}

# ============================================================================
# STEP 5: LAUNCH EC2 INSTANCES (us-east-2)
# ============================================================================

resource "aws_instance" "app" {
  provider                = aws.target
  count                   = var.instance_count
  ami                     = aws_ami_copy.target_ami.id
  instance_type           = var.instance_type
  subnet_id               = count.index == 0 ? aws_subnet.public_1.id : aws_subnet.public_2.id
  vpc_security_group_ids  = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
  }

  monitoring = true

  tags = {
    Name        = "${var.app_name}-instance-${count.index + 1}"
    Environment = var.environment
    Region      = var.target_region
    AMI_ID      = aws_ami_copy.target_ami.id
  }

  depends_on = [aws_ami_copy.target_ami]
}

# ============================================================================
# STEP 6: APPLICATION LOAD BALANCER
# ============================================================================

resource "aws_lb" "main" {
  provider           = aws.target
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  provider    = aws.target
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }

  tags = {
    Name        = "${var.app_name}-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "app" {
  provider         = aws.target
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}

resource "aws_lb_listener" "app" {
  provider          = aws.target
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "source_ami_id" {
  description = "AMI ID created from source instance"
  value       = aws_ami_from_instance.source_ami.id
}

output "target_ami_id" {
  description = "AMI ID in target region (us-east-2)"
  value       = aws_ami_copy.target_ami.id
}

output "ec2_instance_ids" {
  description = "IDs of launched EC2 instances"
  value       = aws_instance.app[*].id
}

output "ec2_instance_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.app[*].public_ip
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "alb_url" {
  description = "URL to access application through load balancer"
  value       = "http://${aws_lb.main.dns_name}"
}
