module "dataproduct_ladenhueter" {
  source = "./modules/dataproduct"

  name = "ladenhueter"
  domain = "fulfillment"

  input = {
    s3_location = "s3://example-com-kafka-connect-stock/topics/stock/"
    format = "JSON"
    schema = "schema.yaml"
  }

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
