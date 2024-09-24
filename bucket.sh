#!/bin/bash

# Carrega as variáveis do arquivo .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[bucket] Erro: Arquivo .env não encontrado."
    exit 1
fi

# Função para criar e verificar bucket
create_and_verify_bucket() {
    local bucket_name=$1
    local bucket_type=$2
    
    # Deleta o bucket se ele existir
    if aws s3 ls "s3://$bucket_name" 2>/dev/null; then
        aws s3 rb "s3://$bucket_name" --force
        echo "$bucket_type Bucket deleted."
    else
        echo "$bucket_type Bucket does not exist."
    fi
    
    # Cria o bucket
    aws s3api create-bucket --bucket "$bucket_name" --region "$AWS_REGION"
    echo "$bucket_type Bucket created."
    
    # Verifica se o bucket foi criado
    if aws s3 ls "s3://$bucket_name" 2>/dev/null; then
        echo "$bucket_type Bucket verified."
    else
        echo "[bucket] Erro: Falha ao criar $bucket_type Bucket."
        exit 1
    fi
}

echo "Setting up buckets..."

# Cria e verifica o bucket principal
create_and_verify_bucket "$AWS_BUCKET_NAME" "backend"

# Cria e verifica o bucket de lambdas
create_and_verify_bucket "$LAMBDA_BUCKET_NAME" "lambda"

echo "Setting up buckets - DONE."

echo "Setting up buckets - DONE."