variable "region" {
  description = "AWS region"
  type        = string
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

variable "subnet_database_cidr_block" {
  description = "CIDR block for the database subnet"
  type        = string
}

variable "subnet_availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
}