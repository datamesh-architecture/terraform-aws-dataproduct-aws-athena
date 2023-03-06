output "aws_glue_database_name" {
  value = aws_glue_catalog_database.aws_glue_catalog_database.name
}

output "aws_glue_catalog_table_name" {
  value = aws_glue_catalog_table.aws_glue_catalog_table.name
}
