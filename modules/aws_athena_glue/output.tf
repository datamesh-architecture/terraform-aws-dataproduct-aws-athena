output "aws_athena_workgroup_name" {
  value = aws_athena_workgroup.aws_athena_workgroup.name
}

output "aws_athena_data_catalog_name" {
  value = aws_athena_data_catalog.aws_athena_data_catalog.name
}

output "aws_glue_database_name" {
  value = aws_glue_catalog_database.aws_glue_catalog_database.name
}

output "aws_glue_catalog_table_name" {
  value = aws_glue_catalog_table.aws_glue_catalog_table.name
}
