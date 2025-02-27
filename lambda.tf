data "archive_file" "backup_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/backup"
  output_path = "${path.module}/lambda_function_backup_payload.zip"
}

# Archive the stop Lambda function code
data "archive_file" "stop_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/stop"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# Archive the start Lambda function code
data "archive_file" "start_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/start"
  output_path = "${path.module}/lambda_function_start_payload.zip"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_valheim_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.inactivity_rule.arn
}

resource "aws_lambda_function" "stop_valheim_instance" {
  filename         = data.archive_file.stop_lambda_zip.output_path
  function_name    = "stop_valheim_instance"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256(data.archive_file.stop_lambda_zip.output_path)
}

resource "aws_api_gateway_rest_api" "valheim_control" {
  name        = "ValheimControl"
  description = "API to control Valheim server"
}

resource "aws_api_gateway_resource" "start_instance" {
  rest_api_id = aws_api_gateway_rest_api.valheim_control.id
  parent_id   = aws_api_gateway_rest_api.valheim_control.root_resource_id
  path_part   = "start"
}

resource "aws_api_gateway_method" "start_instance" {
  rest_api_id   = aws_api_gateway_rest_api.valheim_control.id
  resource_id   = aws_api_gateway_resource.start_instance.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "start_instance" {
  rest_api_id             = aws_api_gateway_rest_api.valheim_control.id
  resource_id             = aws_api_gateway_resource.start_instance.id
  http_method             = aws_api_gateway_method.start_instance.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_valheim_instance.invoke_arn
}

resource "aws_lambda_function" "start_valheim_instance" {
  filename         = data.archive_file.start_lambda_zip.output_path
  function_name    = "start_valheim_instance"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256(data.archive_file.start_lambda_zip.output_path)
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_valheim_instance.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.valheim_control.execution_arn}/*/*"
}

resource "aws_lambda_function" "backup_valheim_instance" {
  filename         = data.archive_file.backup_lambda_zip.output_path
  function_name    = "backup_valheim_instance"
  role             = aws_iam_role.backup_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256(data.archive_file.backup_lambda_zip.output_path)
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.valheim_backup.bucket
    }
  }
}
