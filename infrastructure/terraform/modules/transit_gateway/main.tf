# Transit Gateway for centralized routing
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for ${var.environment} environment"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name        = "tgw-${var.environment}"
    Environment = var.environment
  }
}

# VPC attachment to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id

  tags = {
    Name        = "tgw-attachment-${var.environment}"
    Environment = var.environment
  }
}

# Route table for Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "tgw-route-table-${var.environment}"
    Environment = var.environment
  }
}

# Associate VPC attachment with route table
resource "aws_ec2_transit_gateway_route_table_association" "main" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Propagate routes
resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}