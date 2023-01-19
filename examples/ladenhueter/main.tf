

module "ladenhueter" {
  source = "../../" # Will be GitHub URL or registry in the future
  version = "0.0.1" # Version of the source we're using

  name = "ladenhueter"
  domain = "fulfillment"

  schedule = {
    cron = "0 1 * * *" # Execute every day at 1 A.M.
  }

  input = {
    s3_location = "s3://example-com-kafka-connect-stock/topics/stock/"
    format = "JSON"
    schema = "stock_updated_schema.yaml"
  }

  # Create lambda
  transformation = {
    query = "transform.sql"
  }

  output = {
    format = "PARQUET"
    data = "s3://example-com-dataproducts-fulfillment-ladenhueter/output/data/"
    schema = "s3://example-com-dataproducts-fulfillment-ladenhueter/output/schema.yaml"
    allowed_roles = ["team_coo_support"]
  }
}

module "topic_stock_to_s3" {
  source = "./modules/kafka_connect_topic_to_s3"

  topic = "stock"
  s3_bucket_name = "s3://example-com-kafka-connect-stock"
}
