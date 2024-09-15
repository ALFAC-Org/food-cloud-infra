# TODO: RESOLVER ->. Error: creating Lambda Function (valida_cpf_usuario): operation error Lambda: CreateFunction, https response error StatusCode: 403, RequestID: 91b59148-3910-4fcf-bc40-990f7553ec51, api error AccessDeniedException: Cross-account pass role is not allowed.
# # Security Group for Lambda
# resource "aws_security_group" "lambda_sg" {
#   name        = "lambda_sg"
#   description = "Allow traffic for Lambda function"
#   # vpc_id      = aws_subnet.food_private_subnet_1.vpc_id
#   vpc_id = aws_vpc.food_vpc.id

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
#   tags = {
#     Name = "lambda_sg"
#   }
# }

# # Lambda function configuration
# resource "aws_lambda_function" "valida_cpf_usuario" {
#   function_name = "valida_cpf_usuario"
#   role          = "arn:aws:iam::819532756232:role/LabRole"
#   handler       = "index.handler"
#   runtime       = "nodejs18.x"
#   s3_bucket     = "lambdas-food-bucket" #placeholder lambda
#   s3_key        = "lambda_placeholder.zip"
#   vpc_config {
#     subnet_ids = [
#       aws_subnet.food_private_subnet_1.id,
#       aws_subnet.food_private_subnet_2.id,
#       aws_subnet.food_public_subnet_1.id,
#       aws_subnet.food_public_subnet_1.id
#     ]
#     security_group_ids = [
#       aws_security_group.lambda_sg.id,
#       aws_security_group.eks_security_group.id
#     ]
#   }

#   # Adicionando depends_on para garantir a ordem correta da dependência entre security groups
#   depends_on = [
#     # aws_security_group.food_db_sg,
#     aws_security_group.eks_security_group
#   ]
# }
