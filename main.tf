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
