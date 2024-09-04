output "vpc_id_consumable" {
  value       = "${aws_vpc.food_vpc.id}"
  description = "This is the VPC ID for later use"
}

output "private_subnet_id" {
  value       = "${aws_subnet.food_private_subnet.id}"
  description = "This is the Private Subnet ID for later use"
}

output "public_subnet_id" {
  value       = "${aws_subnet.food_public_subnet.id}"
  description = "This is the Public Subnet ID for later use"
}

output "database_subnet_id" {
  value       = "${aws_subnet.food_database_subnet.id}"
  description = "This is the Database Subnet ID for later use"
}