#!/bin/bash

# Verifica se o método foi passado como argumento
if [ -z "$1" ]; then
    echo "[terraform] Erro: Nenhum método especificado (plan, apply, etc.)."
    exit 1
fi

METHOD=$1

terraform $METHOD \
# Application configuration
-var "environment=${ env.ENVIRONMENT}" \
-var "image_name=${ env.IMAGE_NAME }" \
-var "image_version=${ env.IMAGE_VERSION }" \
-var "app_port=${ env.APP_PORT }" \
# AWS provider configuration
-var "aws_region=${ env.AWS_REGION }" \
-var "node_role_arn=${ env.ARN_AWS_LAB_ROLE }" \
# VPC configuration
-var "vpc_cidr_block=${ env.VPC_CIDR_BLOCK }" \
-var "subnet_private_1_cidr_block=${ env.SUBNET_PRIVATE_1_CIDR_BLOCK }" \
-var "subnet_private_2_cidr_block=${ env.SUBNET_PRIVATE_2_CIDR_BLOCK }" \
-var "subnet_public_1_cidr_block=${ env.SUBNET_PUBLIC_1_CIDR_BLOCK }" \
-var "subnet_public_2_cidr_block=${ env.SUBNET_PUBLIC_2_CIDR_BLOCK }" \
-var "subnet_database_1_cidr_block=${ env.SUBNET_DATABASE_1_CIDR_BLOCK }" \
-var "subnet_database_2_cidr_block=${ env.SUBNET_DATABASE_2_CIDR_BLOCK }" \
-var "subnet_availability_zone_az_1=${ env.SUBNET_AVAILABILITY_ZONE_AZ_1 }" \
-var "subnet_availability_zone_az_2=${ env.SUBNET_AVAILABILITY_ZONE_AZ_2 }" \
# Database configuration
-var "db_username=${ env.DB_USERNAME }" \
-var "db_password=${ env.DB_PASSWORD }" \
# Kubernetes configuration
-var "kubernetes_namespace=${ env.CLUSTER_NAMESPACE }"
