locals {
  aws_lambda_function_name = "${var.product.domain}_${var.product.name}"

  transform_out_directory  = "${path.root}/out_transform"
  transform_out_archive    = "archive_${var.product.domain}_${var.product.name}.zip"

  info_out_directory       = "${path.root}/out_info"
  info_out_archive         = "archive_${var.product.domain}_${var.product.name}-info.zip"

  out_directory            = "${path.root}/out_archives"

  product_input = jsondecode(data.http.input.response_body)
}

data "http" "input" {
  url = var.product.input[0].source

  request_headers = {
    Accept = "application/json"
  }
}

resource "local_file" "query_to_s3" {
  content = templatefile("${path.module}/templates/transform.sql.tftpl", {
    name     = var.product.name
    location = "s3://${var.s3_bucket.bucket}/output/data/"
    format   = var.product.output.format
    query    = file("${path.cwd}/${var.product.transform.query}")
  })
  filename = "${local.transform_out_directory}/query_${var.product.domain}_${var.product.name}.sql"
}

resource "local_file" "lambda_to_s3" {
  content = templatefile("${path.module}/templates/transform.py.tftpl", {
    name             = "query_${var.product.domain}_${var.product.name}"

    athena_output    = "s3://${var.s3_bucket.bucket}/athena/"
    athena_workgroup = local.product_input.output.athena_workgroup
    athena_catalog   = local.product_input.output.athena_catalog
    glue_database    = local.product_input.output.glue_database
  })
  filename = "${local.transform_out_directory}/lambda_function.py"
}

data "archive_file" "archive_to_s3" {
  type = "zip"

  source_dir  = local.transform_out_directory
  output_path = "${local.out_directory}/${local.transform_out_archive}"

  depends_on = [ local_file.query_to_s3, local_file.lambda_to_s3 ]
}

resource "aws_s3_object" "archive_to_s3_object" {
  bucket = var.s3_bucket.bucket

  key    = "lambdas/${local.transform_out_archive}"
  source = data.archive_file.archive_to_s3.output_path
  etag   = data.archive_file.archive_to_s3.output_md5

  depends_on = [ data.archive_file.archive_to_s3 ]
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_s3_input" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      local.product_input.output.location,
      "${local.product_input.output.location}/*"
    ]
  }
}

data "aws_iam_policy_document" "allow_s3" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      var.s3_bucket.arn,
      "${var.s3_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "allow_logging" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "allow_athena" {
  statement {
    actions = [
      "athena:GetDataCatalog",
      "athena:StartQueryExecution"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

data "aws_iam_policy_document" "allow_glue" {
  statement {
    actions = [
      "glue:CreateTable",
      "glue:GetDatabase",
      "glue:GetSchemaVersion",
      "glue:GetTable"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "s3-lambda-execution-role-${var.product.domain}-${var.product.name}"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "lambda_s3" {
  name   = "lambda-execution-s3-policy"
  policy = data.aws_iam_policy_document.allow_s3.json
  role   = aws_iam_role.lambda_execution_role.id
}

resource "aws_iam_role_policy" "lambda_s3_input" {
  name   = "lambda-execution-s3-input-policy"
  policy = data.aws_iam_policy_document.allow_s3_input.json
  role   = aws_iam_role.lambda_execution_role.id
}

resource "aws_iam_role_policy" "lambda_logs" {
  name   = "lambda-execution-logs-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.allow_logging.json
}

resource "aws_iam_role_policy" "lambda_athena" {
  name   = "lambda-execution-athena-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.allow_athena.json
}

resource "aws_iam_role_policy" "lambda_glue" {
  name   = "lambda-execution-glue-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.allow_glue.json
}

resource "aws_lambda_function" "aws_lambda_function" {
  function_name     = local.aws_lambda_function_name

  s3_bucket         = var.s3_bucket.bucket
  s3_key            = aws_s3_object.archive_to_s3_object.key
  s3_object_version = aws_s3_object.archive_to_s3_object.version_id

  runtime           = "python3.9"
  handler           = "lambda_function.lambda_handler"
  source_code_hash  = data.archive_file.archive_to_s3.output_base64sha256

  role = aws_iam_role.lambda_execution_role.arn
}

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
  schedule_expression = "cron(${var.product.schedule})"
}

resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.aws_cloudwatch_event_rule.name
  target_id = aws_lambda_function.aws_lambda_function.id
  arn       = aws_lambda_function.aws_lambda_function.arn
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// INFO

resource "local_file" "lambda_info_to_s3" {
  content = templatefile("${path.module}/templates/info.js.tftpl", {
    response_message = jsonencode({
      domain = var.product.domain
      name   = var.product.name
      output = {
        location = "${var.s3_bucket.arn}/output/data/"
      }
    })
  })
  filename = "${local.info_out_directory}/lambda_function.js"
}

data "archive_file" "archive_info_to_s3" {
  type = "zip"

  source_dir  = local.info_out_directory
  output_path = "${local.out_directory}/${local.info_out_archive}"

  depends_on = [ local_file.lambda_info_to_s3 ]
}

resource "aws_s3_object" "archive_info_to_s3_object" {
  bucket = var.s3_bucket.bucket

  key    = "lambdas/${local.info_out_archive}"
  source = data.archive_file.archive_info_to_s3.output_path
  etag   = data.archive_file.archive_info_to_s3.output_md5

  depends_on = [ data.archive_file.archive_info_to_s3 ]
}

resource "aws_lambda_function" "lambda_info" {
  function_name     = "${var.product.domain}_${var.product.name}_info"

  s3_bucket         = var.s3_bucket.bucket
  s3_key            = aws_s3_object.archive_info_to_s3_object.key
  s3_object_version = aws_s3_object.archive_info_to_s3_object.version_id

  runtime           = "nodejs12.x"
  handler           = "lambda_function.handler"
  source_code_hash  = data.archive_file.archive_info_to_s3.output_base64sha256

  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_apigatewayv2_api" "lambda_info" {
  name          = "${var.product.domain}_${var.product.name}_info"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_info_prod" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_info.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda_info" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  integration_uri    = aws_lambda_function.lambda_info.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_info" {
  api_id = aws_apigatewayv2_api.lambda_info.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_info.id}"
}

resource "aws_cloudwatch_log_group" "lambda_info" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda_info.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "lambda_info" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_info.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_info.execution_arn}/*/*"
}
