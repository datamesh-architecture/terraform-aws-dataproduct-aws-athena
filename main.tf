locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}

module "aws_s3" {
  source = "./modules/aws_s3"
  s3_bucket_name = local.product_fqn
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  s3_bucket = module.aws_s3.s3_bucket

  product = {
    domain    = var.domain
    name      = var.name
    schedule  = var.schedule
    input     = var.input
    transform = var.transform
    output    = var.output
  }
}
