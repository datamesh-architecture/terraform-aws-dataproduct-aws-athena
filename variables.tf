variable "aws" {
  type = object({
    region     = string
    access_key = string
    secret_key = string
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
  }))
  description = "List of URIs to the HTTPS endpoints of existing data products, which should be used as input"
}

variable "transform" {
  type = object({
    query = string
  })
  description = "Path to a SQL file, which should be used to transform the input data"
}

variable "output" {
  type = object({
    format    = string
  })
  description = <<EOT
format: Output format of this data product (e.g. PARQUET)
EOT
}
