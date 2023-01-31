locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}

module "s3_bucket" {
  source = "./modules/aws_s3"

  s3_bucket_name = local.product_fqn
}

module "kafka_sink" {
  source = "./modules/confluent_kafka"

  aws                   = var.aws
  kafka_api_credentials = var.kafka_api_credentials
  kafka                 = var.kafka
  kafka_app_name        = local.product_fqn
  kafka_topics          = [ for input in var.input: input.topic ]

  s3_bucket             = module.s3_bucket.s3_bucket

  depends_on = [ module.s3_bucket ]
}

module "athena_glue" {
  source = "./modules/aws_athena_glue"

  athena_workgroup_name      = var.domain
  athena_database_name       = replace("${local.product_fqn}-data", "-", "_")
  athena_data_catalog_name   = replace(var.domain, "-", "_")

  glue_catalog_database_name = var.domain

  s3_bucket                  = module.s3_bucket.s3_bucket

  product = {
    fqn   = local.product_fqn
    input = var.input
  }

  depends_on = [ module.s3_bucket ]
}

module "lambda" {
  source = "./modules/aws_lambda"

  athena = {
    workgroup = {
      id   = module.athena_glue.aws_athena_workgroup_id
    }
    data_catalog = {
      name = module.athena_glue.aws_athena_data_catalog_name
    }
  }

  s3_bucket                  = module.s3_bucket.s3_bucket

  product = {
    domain    = var.domain,
    name      = var.name,
    schedule  = var.schedule,
    transform = var.transform,
    output    = var.output
  }

  depends_on = [ module.athena_glue, module.s3_bucket ]
}
