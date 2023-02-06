locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}

module "s3_bucket" {
  source = "./modules/aws_s3"

  s3_bucket_name = local.product_fqn
}

module "lambda" {
  source = "./modules/aws_lambda"

  athena = {
    workgroup = {
      id   = var.aws_athena.workgroup.id
    }
    data_catalog = {
      name = var.aws_athena.data_catalog.name
    }
  }

  s3_bucket = module.s3_bucket.s3_bucket

  product = {
    domain    = var.domain,
    name      = var.name,
    schedule  = var.schedule,
    transform = var.transform,
    output    = var.output
  }
}
