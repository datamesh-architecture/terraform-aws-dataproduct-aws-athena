resource "aws_athena_workgroup" "aws_athena_workgroup" {
  name          = var.athena_workgroup_name
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.s3_bucket.bucket}/athena/output/"
    }
  }
}

# Attach glue based data catalog to athena
resource "aws_athena_data_catalog" "aws_athena_data_catalog" {
  description = "Glue based data catalog from data domain ${var.athena_data_catalog_name}"
  name        = var.athena_data_catalog_name
  type        = "GLUE"
  parameters  = {
    "catalog-id" = aws_glue_catalog_database.aws_glue_catalog_database.catalog_id
  }
}

# We want to have one glue catalog database per domain (e.g. fulfillment)
resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = var.glue_catalog_database_name
}

resource "aws_glue_schema" "aws_glue_schema" {
  compatibility     = "DISABLED"
  data_format       = "JSON"
  schema_name       = "schema_${var.product.fqn}"
  schema_definition = file("${path.cwd}/${var.product.input.schema}")
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table_kafka" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  catalog_id    = aws_glue_catalog_database.aws_glue_catalog_database.catalog_id
  name          = var.glue_catalog_table_name
  description   = "Glue catalog table"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "true"
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket.id}/topics/${var.product.input.topic}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    schema_reference {
      schema_version_number = aws_glue_schema.aws_glue_schema.latest_schema_version
      schema_id {
        schema_arn = aws_glue_schema.aws_glue_schema.arn
      }
    }
  }
}
