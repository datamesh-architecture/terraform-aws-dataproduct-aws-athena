variable "kafka_app_name" {
  type = string
}
variable "kafka_topics" {
  type = list(string)
}

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

variable "s3_bucket" {
  type = object({
    bucket = string,
    id     = string,
    arn    = string
  })
}
