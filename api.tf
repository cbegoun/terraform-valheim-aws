resource "aws_api_gateway_rest_api" "valheim_api" {
  name = "ValheimAPI"
}

resource "aws_api_gateway_resource" "start_server" {
  rest_api_id = aws_api_gateway_rest_api.valheim_api.id
  parent_id   = aws_api_gateway_rest_api.valheim_api.root_resource_id
  path_part   = "start-server"
}

resource "aws_api_gateway_method" "start_server_method" {
  rest_api_id   = aws_api_gateway_rest_api.valheim_api.id
  resource_id   = aws_api_gateway_resource.start_server.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.valheim_api.id
  resource_id             = aws_api_gateway_resource.start_server.id
  http_method             = aws_api_gateway_method.start_server_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_valheim_server.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.valheim_api.id
  stage_name  = "prod"
}
