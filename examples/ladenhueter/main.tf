module "ladenhueter" {
  source = "../.."

  product = {
    domain    = "fulfillment",
    name      = "shelf_warmers",
    schedule  = "0 0 * * ? *", # Run at 00:00 am (UTC) every day
    input     = {
      topic     = "stock_updated",
      schema    = "data/stock_updated.schema.json"
    }
    transform = {
      name      = "find_shelf_warmers",
      query     = "data/find_shelf_warmers.sql"
    },
    output    = {
      format    = "PARQUET",
      location  = "shelf_warmers"
    }
  }

  aws                   = var.aws
  kafka_api_credentials = module.kafka_cluster.kafka_api_credentials
  kafka                 = module.kafka_cluster.kafka
}

module "kafka_cluster" {
  source = "./kafka_cluster"

  topic = "stock_updated"
}
