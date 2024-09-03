variable "region" {
  default     = ""
  description = "The default AZ to provision to for the provider"
}

variable "vpc_cidr_block" {
  default     = ""
  description = "The default CIDR block for the VPC demo"
}

variable "subnet_private_cidr_block" {
  default     = ""
  description = "The default CIDR private block for the subnet demo"
}

variable "subnet_public_cidr_block" {
  default     = ""
  description = "The default CIDR public block for the subnet demo"
}

variable "subnet_database_cidr_block" {
  default     = ""
  description = "The default CIDR database block for the subnet demo"
}

variable "subnet_availability_zone" {
  default     = ""
  description = "The default AZ for the subnet"
}