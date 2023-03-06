resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = var.aws_glue_catalog_database_name
}

resource "aws_glue_schema" "aws_glue_schema" {
  compatibility     = "NONE"
  data_format       = "JSON"
  schema_name       = replace(var.table_name, "-", "_")
  schema_definition = file("${path.cwd}/${var.table_schema}")
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  catalog_id    = aws_glue_catalog_database.aws_glue_catalog_database.catalog_id
  name          = replace(var.table_name, "-", "_")
  description   = "Glue catalog table"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL = "true"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket.bucket}/output/data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    schema_reference {
      schema_version_number = aws_glue_schema.aws_glue_schema.latest_schema_version
      schema_id {
        schema_arn = aws_glue_schema.aws_glue_schema.arn
      }
    }
  }
}
