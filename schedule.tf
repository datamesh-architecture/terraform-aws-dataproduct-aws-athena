resource "aws_lambda_permission" "aws_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_function.function_name
  principal     = "events.amazonaws.com"
}

resource "aws_cloudwatch_log_group" "lambda_to_cloudwatch" {
  name = "/aws/lambda/${local.aws_lambda_function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_event_rule" "aws_cloudwatch_event_rule" {
  name                = "schedule_${local.aws_lambda_function_name}"
  description         = "Schedule for Lambda ${local.aws_lambda_function_name}"
  schedule_expression = "cron(${local.product.schedule})"
}

resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.aws_cloudwatch_event_rule.name
  target_id = aws_lambda_function.aws_lambda_function.id
  arn       = aws_lambda_function.aws_lambda_function.arn
}
