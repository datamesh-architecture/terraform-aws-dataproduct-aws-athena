variable "table_name" {
  type = string
}

variable "table_schema" {
  type = string
}

variable "s3_bucket" {
  type = object({
    bucket = string,
    id     = string,
    arn    = string
  })
}

variable "aws_athena_workgroup_name" {
  type = string
}

variable "aws_athena_data_catalog_name" {
  type = string
}

variable "aws_glue_catalog_database_name" {
  type = string
}
