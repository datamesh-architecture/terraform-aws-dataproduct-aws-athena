resource "random_integer" "suffix" {
  min = 10000
  max = 50000
}

locals {
  product_fqn                = replace("${var.product.domain}-${var.product.name}", "_", "-")

  s3_bucket_name             = "${local.product_fqn}-${random_integer.suffix.result}"

  glue_catalog_database_name = "${var.product.domain}-input"
  glue_catalog_table_name    = replace(var.product.name, "-", "_")

  athena_workgroup_name      = var.product.domain
  athena_data_catalog_name   = replace(var.product.domain, "-", "_")
  athena_database_name       = replace("${local.product_fqn}-data", "-", "_")
}

module "s3" {
  source = "./modules/aws_s3"

  s3_bucket_name = local.s3_bucket_name
}

module "kafka_sink" {
  source = "./modules/confluent_kafka"

  aws                   = var.aws

  kafka_api_credentials = var.kafka_api_credentials
  kafka_cluster         = var.kafka_cluster
  kafka_app_name        = local.product_fqn
  kafka_topics          = [ var.product.input.topic ]

  s3_bucket             = module.s3.s3_bucket

  depends_on = [ module.s3 ]
}

module "athena_glue" {
  source = "./modules/aws_athena_glue"

  athena_workgroup_name      = local.athena_workgroup_name
  athena_database_name       = local.athena_database_name
  athena_data_catalog_name   = local.athena_data_catalog_name

  glue_catalog_database_name = local.glue_catalog_database_name
  glue_catalog_table_name    = local.glue_catalog_table_name

  s3_bucket                  = module.s3.s3_bucket

  product = {
    fqn   = local.product_fqn
    input = {
      topic  = var.product.input.topic
      schema = var.product.input.schema
    }
  }

  depends_on = [ module.s3 ]
}

module "lambda" {
  source = "./modules/aws_lambda"

  aws_athena_database_name = module.athena_glue.aws_athena_database_name
  aws_athena_workgroup_id  = module.athena_glue.aws_athena_workgroup_id
  s3_bucket                = module.s3.s3_bucket

  product = var.product

  depends_on = [ module.athena_glue, module.s3 ]
}
