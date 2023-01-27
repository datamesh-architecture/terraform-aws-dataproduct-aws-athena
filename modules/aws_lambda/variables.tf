variable "product" {
  type = object({
    domain    = string,
    name      = string,
    schedule  = string,
    input     = object({
      topic     = string,
      schema    = string
    })
    transform = object({
      name      = string,
      query     = string
    }),
    output    = object({
      format    = string,
      location  = string
    })
  })
}

variable "aws_athena_database_name" {}
variable "aws_athena_workgroup_id" {}

variable "s3_bucket" {
  type = object({
    bucket = string,
    id     = string,
    arn    = string
  })
}
