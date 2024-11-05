# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = var.lambda_sg_name
  description = "Allow traffic for Lambda function"
  vpc_id      = aws_vpc.food_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      aws_security_group.api_gw_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.lambda_sg_name
  }
}

# Lambda function configuration
resource "aws_lambda_function" "valida_cpf_usuario" {
  function_name = "valida_cpf_usuario"
  role          = var.node_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  s3_bucket     = var.bucket_food_lambdas
  s3_key        = "valida_cpf_usuario.zip"
  vpc_config {
    subnet_ids = [
      aws_subnet.food_private_subnet_1.id,
      aws_subnet.food_private_subnet_2.id,
    ]
    security_group_ids = [
      aws_security_group.lambda_sg.id,
      aws_security_group.eks_security_group.id
    ]
  }

  # Todas essas variáveis serão sobreescritas pelo repositório do food-serveless
  # Por isso, aqui só criamos um placeholder para evitar que o Terraform faça alterações no futuro
  environment {
    variables = {
      DB_HOST = "THIS_VALUE_WILL_BE_UPDATED_BY_FOOD_SERVELESS_REPOSITORY"
      DB_USERNAME = "THIS_VALUE_WILL_BE_UPDATED_BY_FOOD_SERVELESS_REPOSITORY"
      DB_PASSWORD = "THIS_VALUE_WILL_BE_UPDATED_BY_FOOD_SERVELESS_REPOSITORY"
      DB_NAME = "THIS_VALUE_WILL_BE_UPDATED_BY_FOOD_SERVELESS_REPOSITORY"
      JWT_KEY_TOKEN = "THIS_VALUE_WILL_BE_UPDATED_BY_FOOD_SERVELESS_REPOSITORY"
    }
  }

  # E aqui é onde garantimos que o Terraform não faça alterações nas variáveis de ambiente
  lifecycle {
    ignore_changes = [
      environment[0].variables
    ]
  }

  # Adicionando depends_on para garantir a ordem correta da dependência entre security groups
  depends_on = [
    aws_security_group.eks_security_group,
    aws_s3_object.valida_cpf_usuario,
    aws_security_group.api_gw_sg
  ]
}
