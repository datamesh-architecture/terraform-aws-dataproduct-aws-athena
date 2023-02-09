module "kafka_cluster" {
  source = "./kafka_cluster"

  topics = [ "stock" ]
}

module "shelf_warmers" {
  source = "https://github.com/datamesh-architecture/terraform-datamesh-dataproduct-aws-athena"
  aws                   = var.aws
  kafka_api_credentials = module.kafka_cluster.kafka_api_credentials
  kafka                 = module.kafka_cluster.kafka

  domain    = "fulfillment"
  name      = "shelf_warmers"
  schedule  = "0 0 * * ? *" # Run at 00:00 am (UTC) every day

  input     = [
    {
      topic     = "stock",
      /* format    = "JSON",*/
      table_name = "stock_updated"
      schema    = "schema/stock_updated.schema.json"
    }
  ]

  transform = {
    query     = "sql/transform.sql"
  }

  output    = {
    format    = "PARQUET",
    location  = "shelf_warmers"
  }
}
