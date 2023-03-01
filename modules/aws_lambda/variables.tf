variable "product" {
  type = object({
    domain    = string,
    name      = string,
    schedule  = string,
    input     = list(object({
      source    = string
    }))
    transform = object({
      query     = string
    }),
    output    = object({
      schema    = string
      format    = string
    })
  })
}

variable "s3_bucket" {
  type = object({
    bucket = string,
    id     = string,
    arn    = string
  })
}

variable "athena" {
  type = object({
    data_catalog_name = string,
    workgroup_name    = string
  })
}

variable "glue" {
  type = object({
    database_name = string,
    table_name    = string
  })
}
