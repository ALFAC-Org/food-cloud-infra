# Cria a API Gateway do tipo HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "food_http_api"
  protocol_type = "HTTP"
  description   = "Food HTTP API"
}

# Cria o autorizer Lambda para a HTTP API
resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  api_id         = aws_apigatewayv2_api.http_api.id
  name           = "lambda_authorizer"
  authorizer_type = "REQUEST"
  authorizer_uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.valida_cpf_usuario.arn}/invocations"
  identity_sources = ["$request.header.Authorization"]
}

# Define a rota do API Gateway para aceitar todas as requisições que começam com /pedidos e usar o autorizer Lambda
resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /pedidos/{proxy+}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

# Cria o VPC Link para a integração com o Load Balancer
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name = "food_vpc_link"
  subnet_ids = [
    aws_subnet.food_public_subnet_1.id,
    aws_subnet.food_public_subnet_2.id,
  ]
  security_group_ids = [aws_security_group.api_gw_sg.id]
}

# Define a integração do API Gateway para chamar o Load Balancer
resource "aws_apigatewayv2_integration" "auth_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "http://${data.kubernetes_service.food_app_service_data.status[0].load_balancer[0].ingress[0].hostname}/"
  integration_method = "ANY"
  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.vpc_link.id
  request_parameters = {
    "integration.request.querystring.cpf" = "method.request.querystring.cpf"
  }
}

# Cria o grupo de segurança para o API Gateway
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