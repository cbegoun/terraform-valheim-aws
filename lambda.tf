resource "aws_lambda_function" "start_valheim_server" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "start_valheim_server"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "start_valheim_server.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"

  environment {
    variables = {
      INSTANCE_ID = aws_instance.valheim.id
    }
  }
}

resource "aws_lambda_permission" "api_gateway_invocation" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_valheim_server.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.valheim_api.execution_arn}/*/*"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function_payload.zip"
}
