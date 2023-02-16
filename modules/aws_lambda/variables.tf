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
