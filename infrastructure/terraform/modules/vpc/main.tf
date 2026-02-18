################################################################################
# VPC Module - Main Configuration
################################################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-public-subnet-${var.availability_zones[count.index]}"
      Type = "Public"
      Tier = "Public"
    }
  )
}

################################################################################
# Private Subnets (for ECS, Lambda, etc.)
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-private-subnet-${var.availability_zones[count.index]}"
      Type = "Private"
      Tier = "Application"
    }
  )
}

################################################################################
# Database Subnets
################################################################################

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-database-subnet-${var.availability_zones[count.index]}"
      Type = "Private"
      Tier = "Database"
    }
  )
}

################################################################################
# Elastic IPs for NAT Gateways
################################################################################

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

################################################################################
# NAT Gateways
################################################################################

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-nat-${var.availability_zones[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

################################################################################
# Route Tables - Public
################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-public-rt"
      Type = "Public"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

################################################################################
# Route Tables - Private
################################################################################

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 1

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${local.name_prefix}-private-rt" : "${local.name_prefix}-private-rt-${var.availability_zones[count.index]}"
      Type = "Private"
    }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

################################################################################
# Route Tables - Database
################################################################################

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-database-rt"
      Type = "Private"
      Tier = "Database"
    }
  )
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

################################################################################
# VPC Flow Logs (Optional - Best Practice)
################################################################################

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-vpc-flow-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.name_prefix}-flow-logs"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-vpc-flow-logs"
    }
  )
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

################################################################################
# VPC Endpoints - S3 Gateway Endpoint
################################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.database.id != null ? [aws_route_table.database.id] : []
  )

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-s3-endpoint"
    }
  )
}

################################################################################
# VPC Endpoints - DynamoDB Gateway Endpoint
################################################################################

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.database.id != null ? [aws_route_table.database.id] : []
  )

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-dynamodb-endpoint"
    }
  )
}

################################################################################
# Data Source - Current AWS Region
################################################################################

data "aws_region" "current" {}

################################################################################
# CloudWatch Dashboard - NAT Gateway Monitoring
################################################################################

resource "aws_cloudwatch_dashboard" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  dashboard_name = "${local.name_prefix}-nat-gateway-dashboard"

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
            for i in range(length(aws_nat_gateway.main)) : [
              "AWS/NATGateway",
              "BytesInFromDestination",
              "NatGatewayId",
              aws_nat_gateway.main[i].id
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "NAT Gateway Bytes In From Destination"
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
            for i in range(length(aws_nat_gateway.main)) : [
              "AWS/NATGateway",
              "BytesOutToDestination",
              "NatGatewayId",
              aws_nat_gateway.main[i].id
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "NAT Gateway Bytes Out To Destination"
        }
      }
    ]
  })
}
