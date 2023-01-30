locals {
  aws_lambda_function_name = "${var.product.domain}_${var.product.name}"

  out_directory       = "${path.root}/output"
  out_product_archive = "archive_${var.product.domain}_${var.product.name}.zip"
}

resource "local_file" "query_to_s3" {
  content = templatefile("${path.module}/templates/to-s3.sql.tftpl", {
    name     = var.product.name
    location = "s3://${var.s3_bucket.bucket}/output/data/"
    format   = var.product.output.format
    query    = file("${path.cwd}/${var.product.transform.query}")
  })
  filename = "${local.out_directory}/query_${var.product.domain}_${var.product.name}.sql"
}

resource "local_file" "lambda_to_s3" {
  content = templatefile("${path.module}/templates/lambda_function.py.tftpl", {
    name             = "query_${var.product.domain}_${var.product.name}"
    glue_database    = var.product.domain
    athena_workgroup = var.aws_athena_workgroup_id
    athena_catalog   = var.aws_athena_data_catalog_name
  })
  filename = "${local.out_directory}/lambda_function.py"
}

data "archive_file" "archive_to_s3" {
  type = "zip"

  source_dir  = local.out_directory
  output_path = "${local.out_directory}/${local.out_product_archive}"

  depends_on = [local_file.query_to_s3, local_file.lambda_to_s3]
}

resource "aws_s3_object" "archive_to_s3_object" {
  bucket = var.s3_bucket.bucket

  key    = "lambdas/${local.out_product_archive}"
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

data "aws_iam_policy_document" "allow_s3" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject*",
      "s3:GetEncryptionConfiguration",
      "s3:PutObject",
      "s3:PutEncryptionConfiguration",
    ]

    resources = [
      var.s3_bucket.arn,
      "${var.s3_bucket.arn}/*",
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
      "athena:*"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

data "aws_iam_policy_document" "allow_glue" {
  statement {
    actions = [
      "glue:*" // ToDo
      //"glue:GetDatabase",
      //"glue:GetTable",
      //"glue:ListSchemas",
      //"glue:CreateTable"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "s3-lambda-execution-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "lambda_s3" {
  name   = "lambda-execution-s3-policy"
  policy = data.aws_iam_policy_document.allow_s3.json
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
