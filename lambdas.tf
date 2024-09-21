# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Allow traffic for Lambda function"
  vpc_id      = aws_vpc.food_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # TODO: Allow API-GATEWAY
    cidr_blocks = ["0.0.0.0/0"]
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

  # environment {
  #   variables = {
  #     DB_HOST     = aws_db_instance.food_database.address
  #     DB_USER     = var.db_username
  #     DB_PASSWORD = var.db_password
  #     DB_NAME     = "fooddb"
  #   }
  # }

  # Adicionando depends_on para garantir a ordem correta da dependência entre security groups
  depends_on = [
    aws_security_group.eks_security_group,
    aws_s3_object.valida_cpf_usuario
  ]
}
