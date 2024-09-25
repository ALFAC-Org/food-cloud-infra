# Cria a API Gateway dentro da VPC
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "food_api_gateway"
  description = "Food API Gateway"
  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.api_gw_vpc_endpoint.id]
  }
}

# Cria o VPC Endpoint para o API Gateway
resource "aws_vpc_endpoint" "api_gw_vpc_endpoint" {
  vpc_id            = aws_vpc.food_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.food_public_subnet_1.id,
    aws_subnet.food_public_subnet_2.id,
  ]
  security_group_ids = [aws_security_group.api_gw_sg.id]
}

# Cria o recurso do API Gateway
resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "auth"
}

# Cria o recurso do API Gateway para proxy
resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.auth_resource.id
  path_part   = "{proxy+}"
}

# Cria o autorizer Lambda
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  rest_api_id     = aws_api_gateway_rest_api.rest_api.id
  name            = "lambda_authorizer"
  type            = "TOKEN"
  authorizer_uri  = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.valida_cpf_usuario.arn}/invocations"
  identity_source = "method.request.header.Authorization"
}

# Define o método do API Gateway para aceitar um parâmetro e usar o autorizer Lambda
resource "aws_api_gateway_method" "auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.auth_resource.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.cpf" = true
    "method.request.header.auth" = true
  }

  
}

# Define a integração do API Gateway para chamar o Load Balancer
resource "aws_api_gateway_integration" "auth_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.auth_resource.id
  http_method             = aws_api_gateway_method.auth_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${data.kubernetes_service.food_app_service_data.status[0].load_balancer[0].ingress[0].hostname}/"

  depends_on = [
    kubernetes_service.food_app_service,
    aws_lambda_function.valida_cpf_usuario
  ]
}

# # Cria o Load Balancer - TODO: apontar para o nosso LB ja criado
# resource "aws_lb" "my_lb" {
#   name               = "my-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = var.subnet_ids
# }

# Cria o grupo de segurança para o API Gateway - Precisamos de um grupo de segurança para o API Gateway?
resource "aws_security_group" "api_gw_sg" {
  name        = "api-gw-sg"
  description = "Allow API Gateway access"
  vpc_id      = aws_vpc.food_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria o grupo de segurança para o Load Balancer - TOD0: Ja devemos ter, validar se precisamos
# resource "aws_security_group" "lb_sg" {
#   name        = "lb-sg"
#   description = "Allow Load Balancer access"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# Define as respostas do método
resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "method_response_400" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = "400"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }

  response_models = {
    "application/json" = "Error"
  }
}

# Define as respostas da integração
resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "integration_response_400" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = aws_api_gateway_method_response.method_response_400.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }

  response_templates = {
    "application/json" = ""
  }
}
