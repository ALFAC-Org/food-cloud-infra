variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_private_cidr_block" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "subnet_public_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "subnet_availability_zone_az_1" {
  description = "Availability zone for the subnets"
  type        = string
}

variable "arn_aws_lab_role" {
  description = "ARN for the IAM role"
  type        = string
}