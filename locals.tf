# locals.tf
locals {
  # Use the provided vpc_id if it's not empty, otherwise use the VPC created in this config
  actual_vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.main.id
  
  # You can add other local values here in the future
}