locals {
  aws_lambda_function_name = "${local.product.domain}_${local.product.name}"

  transform_out_directory  = "${path.root}/out_transform"
  transform_out_archive    = "archive_${local.product.domain}_${local.product.name}.zip"

  info_out_directory       = "${path.root}/out_info"
  info_out_archive         = "archive_${local.product.domain}_${local.product.name}-info.zip"

  out_directory            = "${path.root}/out_archives"
}

resource "local_file" "query_to_s3" {
  content = templatefile("${path.module}/templates/transform.sql.tftpl", {
    location = "s3://${aws_s3_bucket.aws_s3_bucket.bucket}/output/data/"
    format   = local.product.output.format
    database = aws_glue_catalog_database.aws_glue_catalog_database.name
    name     = aws_glue_catalog_table.aws_glue_catalog_table.name
    query    = file("${path.cwd}/${local.product.transform.query}")
  })
  filename = "${local.transform_out_directory}/query_${local.product.domain}_${local.product.name}.sql"
}

resource "local_file" "lambda_to_s3" {
  content = templatefile("${path.module}/templates/transform.py.tftpl", {
    name             = "query_${local.product.domain}_${local.product.name}"

    athena_output    = "s3://${aws_s3_bucket.aws_s3_bucket.bucket}/athena/"
    glue_database    = aws_glue_catalog_database.aws_glue_catalog_database.name
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
  bucket = aws_s3_bucket.aws_s3_bucket.bucket

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
      local.product.input[0].source,
      "${local.product.input[0].source}/*"
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
      aws_s3_bucket.aws_s3_bucket.arn,
      "${aws_s3_bucket.aws_s3_bucket.arn}/*"
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
      "glue:GetTable",
      "glue:GetPartitions"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

data "aws_iam_policy_document" "allow_kms" {
  statement {
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = [
      "*" // ToDo
    ]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "s3-lambda-execution-role-${local.product.domain}-${local.product.name}"

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

resource "aws_iam_role_policy" "lambda_kms" {
  name   = "lambda-execution-kms-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.allow_kms.json
}


resource "aws_lambda_function" "aws_lambda_function" {
  function_name     = local.aws_lambda_function_name

  s3_bucket         = aws_s3_bucket.aws_s3_bucket.bucket
  s3_key            = aws_s3_object.archive_to_s3_object.key
  s3_object_version = aws_s3_object.archive_to_s3_object.version_id

  runtime           = "python3.9"
  handler           = "lambda_function.lambda_handler"
  source_code_hash  = data.archive_file.archive_to_s3.output_base64sha256

  role = aws_iam_role.lambda_execution_role.arn
}
