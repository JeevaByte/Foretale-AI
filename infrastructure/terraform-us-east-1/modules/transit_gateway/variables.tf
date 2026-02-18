variable "environment" {
  description = "Environment tag (DEV/UAT/PROD)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach to Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of subnets for Transit Gateway attachment"
  type        = list(string)
}