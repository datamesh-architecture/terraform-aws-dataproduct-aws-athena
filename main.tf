locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
  product     = {
    domain    = var.domain
    name      = var.name
    schedule  = var.schedule
    input     = var.input
    transform = var.transform
    output    = var.output
  }
}

module "aws_s3" {
  source = "./modules/aws_s3"
  s3_bucket_name = local.product_fqn
}

module "aws_athena_glue" {
  source = "./modules/aws_athena_glue"

  s3_bucket                      = module.aws_s3.s3_bucket
  aws_athena_data_catalog_name   = replace(var.domain, "_", "-")
  aws_athena_workgroup_name      = replace(var.domain, "_", "-")
  aws_glue_catalog_database_name = replace(var.domain, "_", "-")

  table_name   = local.product_fqn
  table_schema = var.output.schema
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  s3_bucket     = module.aws_s3.s3_bucket
  athena        = {
    data_catalog_name = module.aws_athena_glue.aws_athena_data_catalog_name
    workgroup_name    = module.aws_athena_glue.aws_athena_workgroup_name
  }
  glue = {
    database_name = module.aws_athena_glue.aws_glue_database_name
    table_name    = module.aws_athena_glue.aws_glue_catalog_table_name
  }

  product = local.product
}
