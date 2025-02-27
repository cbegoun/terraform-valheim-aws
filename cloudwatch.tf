resource "aws_cloudwatch_event_rule" "inactivity_rule" {
  name                = "inactivity_rule"
  description         = "Trigger Lambda function after 15 minutes of inactivity"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "inactivity_target" {
  rule      = aws_cloudwatch_event_rule.inactivity_rule.name
  target_id = "stop_valheim_instance"
  arn       = aws_lambda_function.stop_valheim_instance.arn
}

resource "aws_cloudwatch_event_rule" "backup_rule" {
  name                = "backup_rule"
  description         = "Trigger Lambda function to backup Valheim server every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "backup_target" {
  rule      = aws_cloudwatch_event_rule.backup_rule.name
  target_id = "backup_valheim_instance"
  arn       = aws_lambda_function.backup_valheim_instance.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_backup" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_valheim_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_rule.arn
}