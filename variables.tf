variable "aws" {
  type = object({
    region     = string
    access_key = string
    secret_key = string
  })
}

variable "aws_athena" {
  type = object({
    workgroup = object({
      id = string
    })
    data_catalog = object({
      name = string
    })
  })
}

variable "domain" {
  type = string
  description = "The domain of the data product"
}

variable "name" {
  type = string
  description = "The name of the data product"
}

variable "schedule" {
  type = string
  description = "The schedule expression to pass to the EventBridge event rule. Format: Minutes | Hours | Day of month | Month | Day of week | Year"
  default = ""
}

variable "input" {
  type = list(object({
    source     = string
    format     = string
    table_name = string
    schema     = string
  }))
  description = ""
}

variable "transform" {
  type = object({
    query = string
  })
  description = ""
}

variable "output" {
  type = object({
    format    = string
    location  = string
  })
  description = ""
}
