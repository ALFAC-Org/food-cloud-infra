output "vpc_id_consumable" {
  value       = "${aws_vpc.food_vpc.id}"
  description = "This is the VPC ID for later use"
}

output "private_subnet_1_id" {
  value       = "${aws_subnet.food_private_subnet_1.id}"
  description = "This is the first Private Subnet ID for later use"
}

output "private_subnet_2_id" {
  value       = "${aws_subnet.food_private_subnet_2.id}"
  description = "This is the second Private Subnet ID for later use"
}

output "public_subnet_1_id" {
  value       = "${aws_subnet.food_public_subnet_1.id}"
  description = "This is the first Public Subnet ID for later use"
}

output "public_subnet_2_id" {
  value       = "${aws_subnet.food_public_subnet_2.id}"
  description = "This is the second Public Subnet ID for later use"
}

# output "database_subnet_id_1" {
#   value       = "${aws_subnet.food_database_subnet_az_1.id}"
#   description = "This is the Database Subnet ID for later use"
# }

# output "database_subnet_id_2" {
#   value       = "${aws_subnet.food_database_subnet_az_2.id}"
#   description = "This is the Database Subnet ID for later use"
# }

output "app_name" {
  value = kubernetes_service.food_app_service.metadata[0].name
}

output "load_balancer_hostname" {
  value = data.kubernetes_service.food_app_service_data.status[0].load_balancer[0].ingress[0].hostname
}

output "ingress_port" {
  value = kubernetes_ingress_v1.food_app_ingress.spec[0].default_backend[0].service[0].port[0].number
}
