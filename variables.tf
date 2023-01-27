variable "aws" {
  type = object({
    region     = string
    access_key = string
    secret_key = string
  })
}

variable "kafka_api_credentials" {
  type = object({
    api_key_id = string
    api_key_secret = string
  })
}

variable "kafka" {
  type = object({
    environment = object({
      id = string
    })
    cluster = object({
      id = string
      rest_endpoint = string
    })
  })
}

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
  description = <<EOT
    product = {
      domain    = "The corresponding domain name of the data product"
      name      = "The name of the data product"
      schedule  = "The schedule expression to pass to the EventBridge event rule. Format: Minutes | Hours | Day of month | Month | Day of week | Year"
      input     = {
        topic     = ""
        schema    = ""
      }
      transform = {
        name      = ""
        query     = ""
      }
      output    = {
        format    = ""
        location  = ""
      }
    }
  EOT
}
