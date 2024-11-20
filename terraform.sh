#!/bin/bash

# Carrega as variáveis do arquivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[terraform] Erro: Arquivo .env não encontrado."
    exit 1
fi

# Verifica se o método foi passado como argumento
if [ -z "$1" ]; then
    echo "[terraform] Erro: Nenhum método especificado (plan, apply, etc.)."
    exit 1
fi

METHOD=$1
shift

PARAMS="$@"

terraform $METHOD $PARAMS \
-var "environment=$ENVIRONMENT" \
-var "image_name=$IMAGE_NAME" \
-var "image_username=$DOCKERHUB_USERNAME" \
-var "image_version=$IMAGE_VERSION" \
-var "app_port=$APP_PORT" \
-var "app_service_port=$FOOD_SERVICE_PORT" \
-var "enable_flyway=$ENABLE_FLYWAY" \
-var "aws_region=$AWS_REGION" \
-var "node_role_arn=$ARN_AWS_LAB_ROLE" \
-var "vpc_name=$VPC_NAME" \
-var "vpc_cidr_block=$VPC_CIDR_BLOCK" \
-var "subnet_private_1_cidr_block=$SUBNET_PRIVATE_1_CIDR_BLOCK" \
-var "subnet_private_2_cidr_block=$SUBNET_PRIVATE_2_CIDR_BLOCK" \
-var "subnet_public_1_cidr_block=$SUBNET_PUBLIC_1_CIDR_BLOCK" \
-var "subnet_public_2_cidr_block=$SUBNET_PUBLIC_2_CIDR_BLOCK" \
-var "subnet_availability_zone_az_1=$SUBNET_AVAILABILITY_ZONE_AZ_1" \
-var "subnet_availability_zone_az_2=$SUBNET_AVAILABILITY_ZONE_AZ_2" \
-var "db_username=$DB_USERNAME" \
-var "db_password=$DB_PASSWORD" \
-var "db_name=$DB_NAME" \
-var "db_host=$DB_HOST" \
-var "kubernetes_namespace=$CLUSTER_NAMESPACE" \
-var "cluster_name=$CLUSTER_NAME" \
-var "bucket_food_lambdas=$LAMBDA_BUCKET_NAME" \
-var "food_cliente_image_name=$FOOD_CLIENTE_IMAGE_NAME" \
-var "food_cliente_image_version=$FOOD_CLIENTE_IMAGE_VERSION" \
-var "food_cliente_service_port=$FOOD_CLIENTE_SERVICE_PORT" \
-var "food_cliente_db_username=$DB_FOOD_CLIENT_USERNAME" \
-var "food_cliente_db_password=$DB_FOOD_CLIENT_PASSWORD" \
-var "food_cliente_db_name=$DB_FOOD_CLIENT_NAME" \
-var "food_cliente_db_host=$DB_FOOD_CLIENT_HOST_NAME" \
-var "food_produto_db_table_name=$FOOD_PRODUTO_DB_TABLE_NAME" \
-var "food_produto_service_port=$FOOD_PRODUTO_SERVICE_PORT" \
-var "food_produto_image_version=$FOOD_PRODUTO_VERSION"