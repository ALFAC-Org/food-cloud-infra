#!/bin/bash

# Carrega as variáveis do arquivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[bucket] Erro: Arquivo .env não encontrado."
    exit 1
fi

echo "Setting up buckets..."

# Deleta o bucket principal
if aws s3 ls "s3://$AWS_BUCKET_NAME" 2>/dev/null; then
    aws s3 rb "s3://$AWS_BUCKET_NAME" --force
    echo "Major Bucket deleted."
else
    echo "Major Bucket does not exist."
fi

aws s3api create-bucket --bucket "$AWS_BUCKET_NAME" --region "$AWS_REGION"
echo "Major Bucket created."

# Deleta o bucket de lambdas
if aws s3 ls "s3:/$LAMBDA_BUCKET_NAME" 2>/dev/null; then
    aws s3 rb "s3://$LAMBDA_BUCKET_NAME" --force
    echo "Lambda Bucket deleted."
else
    echo "Lambda Bucket does not exist."
fi

aws s3api create-bucket --bucket "$LAMBDA_BUCKET_NAME" --region "$AWS_REGION"
echo "Lambda Bucket created."

echo "Setting up buckets - DONE."