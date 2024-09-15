# Application configuration
variable "environment" {
  description = "The environment of the application"
  type        = string
  default     = "development"
}

variable "image_version" {
  description = "The version of the image to deploy"
  type        = string
  default     = "latest"
}

variable "image_name" {
  description = "The name of the image to deploy"
  type        = string
  default     = "carlohcs/food-repo:withoutdb"
}

variable "app_port" {
  description = "The port where the application will be listening"
  type        = number
  default     = 8080
}

# AWS provider configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "The AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "The AWS session token"
  type        = string
  sensitive   = true
}

variable "node_role_arn" {
  description = "ARN of the IAM Role that will be associated with the Node Group"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

# VPC configuration
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_public_1_cidr_block" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_public_2_cidr_block" {
  description = "CIDR block for the secondary public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_1_cidr_block" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_private_2_cidr_block" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "subnet_database_1_cidr_block" {
  description = "CIDR block for the database subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "subnet_database_2_cidr_block" {
  description = "CIDR block for the database subnet"
  type        = string
  default     = "10.0.6.0/24"
}

variable "subnet_availability_zone_az_1" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_availability_zone_az_2" {
  description = "Availability zone 2 for the subnets"
  type        = string
  default     = "us-east-1b"
}

# Database configuration
variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  sensitive   = true
  default     = "fooddbuser"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
  default     = "fooddbpass"
}

# Kubernetes configuration
variable "kubernetes_namespace" {
  description = "The Kubernetes namespace where the resources will be provisioned"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "food-cluster"
}
