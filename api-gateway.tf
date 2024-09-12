# # Cria a API Gateway
# resource "aws_api_gateway_rest_api" "rest_api" {
#   name        = "authentication-api"
#   description = "Authentication API Gateway"
# }

# # Cria o recurso do API Gateway
# resource "aws_api_gateway_resource" "auth_resource" {
#   rest_api_id = aws_api_gateway_rest_api.rest_api.id
#   parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
#   path_part   = "auth"
# }

# # Define o método do API Gateway para aceitar um parâmetro
# resource "aws_api_gateway_method" "auth_method" {
#   rest_api_id   = aws_api_gateway_rest_api.rest_api.id
#   resource_id   = aws_api_gateway_resource.auth_resource.id
#   http_method   = "POST"
#   authorization = "NONE"

#   request_parameters = {
#     "method.request.querystring.cpf" = true
#   }
# }

# # Define a integração do API Gateway para chamar o Cognito
# resource "aws_api_gateway_integration" "auth_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.rest_api.id
#   resource_id             = aws_api_gateway_resource.auth_resource.id
#   http_method             = aws_api_gateway_method.auth_method.http_method
#   type                    = "AWS"
#   integration_http_method = "POST"
#   uri                     = "arn:aws:apigateway:${var.region}:cognito-idp:action/AdminInitiateAuth"

#   credentials = var.arn_aws_lab_role

#   request_templates = {
#     "application/json" = <<EOF
#     {
#         "AuthFlow": "CUSTOM_AUTH",
#         "ClientId": "${aws_cognito_user_pool_client.user_pool_client.id}",
#         "UserPoolId": "${aws_cognito_user_pool.user_pool.id}",
#         "AuthParameters": {
#             "USERNAME": "$input.params('cpf')",
#             "PASSWORD": "password"
#         }
#     }
#     EOF
#   }

#   request_parameters = {
#     "integration.request.querystring.cpf" = "method.request.querystring.cpf"
#   }

#   passthrough_behavior = "WHEN_NO_MATCH"
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   depends_on = [aws_api_gateway_integration.auth_integration]
#   rest_api_id = aws_api_gateway_rest_api.rest_api.id
#   stage_name  = "prod"
# }

# # Cognito User Pool
# resource "aws_cognito_user_pool" "user_pool" {
#   name = "user_pool"

#   lambda_config {
#     pre_authentication = aws_lambda_function.valida_cpf_usuario.arn
#   }

#   auto_verified_attributes = ["email"] #TODO: Validar se precisamos disso
# }

# # Cognito User Pool Client
# resource "aws_cognito_user_pool_client" "user_pool_client" {
#   name         = "user_pool_client"
#   user_pool_id = aws_cognito_user_pool.user_pool.id

#   explicit_auth_flows = ["CUSTOM_AUTH_FLOW_ONLY"]
# }

# # Permissão para a função Lambda ser invocada pelo Cognito
# resource "aws_lambda_permission" "allow_cognito_invoke" {
#   statement_id  = "AllowCognitoInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.valida_cpf_usuario.function_name
#   principal     = "cognito-idp.amazonaws.com"
#   source_arn    = aws_cognito_user_pool.user_pool.arn
# }
