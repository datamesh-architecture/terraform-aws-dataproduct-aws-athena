variable "product" {
  type = object({
    domain    = string,
    name      = string,
    schedule  = string,
    transform = object({
      query     = string
    }),
    output    = object({
      format    = string,
      location  = string
    })
  })
}

variable "athena" {
  type = object({
    workgroup = object({
      id = string
    })
    data_catalog = object({
      name = string
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
