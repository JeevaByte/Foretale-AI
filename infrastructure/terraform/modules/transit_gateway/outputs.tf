output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.main.id
}