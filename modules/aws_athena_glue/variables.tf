variable "glue_catalog_database_name" {}

variable "athena_data_catalog_name" {}
variable "athena_database_name" {}
variable "athena_workgroup_name" {}

variable "s3_bucket" {
  type = object({
    bucket = string,
    id     = string,
    arn    = string
  })
}

variable "product" {
  type = object({
    fqn   = string,
    input = list(object({
      topic = string
      table_name = string
      schema = string
    }))
  })
}
