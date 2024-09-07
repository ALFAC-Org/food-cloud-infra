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

variable "subnet_database_1_cidr_block" {
  description = "CIDR block for the database subnet"
  type        = string
}

variable "subnet_database_2_cidr_block" {
  description = "CIDR block for the database subnet"
  type        = string
}

variable "subnet_availability_zone_az_1" {
  description = "Availability zone for the subnets"
  type        = string
}

variable "subnet_availability_zone_az_2" {
  description = "Availability zone 2 for the subnets"
  type        = string
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}