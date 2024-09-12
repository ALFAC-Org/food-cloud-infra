# # Security Group for Lambda
# resource "aws_security_group" "lambda_sg" {
#   name        = "lambda_sg"
#   description = "Allow traffic for Lambda function"
#   vpc_id      = aws_subnet.food_private_subnet.vpc_id

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "lambda_sg"
#   }
# }

# # Lambda function configuration
# resource "aws_lambda_function" "valida_cpf_usuario" {
#   function_name = "valida_cpf_usuario"
#   role          = var.arn_aws_lab_role
#   handler       = "index.handler"
#   runtime       = "nodejs18.x"
#   s3_bucket     = "lambdas-food-bucket" #placeholder lambda
#   s3_key        = "lambda_placeholder.zip" 
#   vpc_config {
#     subnet_ids         = [aws_subnet.food_private_subnet.id]
#     security_group_ids = [aws_security_group.lambda_sg.id]
#   }

#   # Adicionando depends_on para garantir a ordem correta da dependência entre security groups
#   depends_on = [aws_security_group.food_db_sg]
# }