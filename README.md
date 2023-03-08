# terraform-dataproduct-aws-athena

This open source Terraform module provisions the necessary services to provide a data product on AWS.

![Overview](https://www.datamesh-architecture.com/images/terraform-dataproduct-aws-athena.png)

## Services

* AWS S3
* AWS Athena
* AWS Glue
* AWS Lambda

## Usage

```hcl
module my_data_product {
  source = "git@github.com:datamesh-architecture/terraform-dataproduct-aws-athena.git"

  domain   = "<data_product_domain>"
  name     = "<data_product_name>"
  
  schedule = "0 0 * * ? *" # Run at 00:00 am (UTC) every day

  input = [
    {
      source = "<existing_s3_bucket>"
    }
  ]

  transform = {
    query = "sql/<name_of_the_transform>.sql"
  }

  output = {
    format   = "<format>"
  }
}
```

## Endpoint data

The module creates an RESTful endpoint via AWS lambda (e.g. https://3jopsshxxc.execute-api.eu-central-1.amazonaws.com/prod/). This endpoint can be used as an input for another data product or to retrieve information about this data product.

```json
{
  "domain": "<data_product_domain>",
  "name": "<data_product_name>",
  "output": {
    "location": "arn:aws:s3:::<s3_bucket_name>/output/data/"
  }
}
```

## Examples

See [examples repository](https://github.com/datamesh-architecture/terraform-dataproduct-examples).

## Authors

This terraform module is maintained by [André Deuerling](https://www.innoq.com/en/staff/andre-deuerling/), [Jochen Christ](https://www.innoq.com/en/staff/jochen-christ/), and [Simon Harrer](https://www.innoq.com/en/staff/dr-simon-harrer/).

## License

MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.56 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.56 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.lambda_info_prod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_event_rule.aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.lambda_to_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_glue_catalog_database.aws_glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_catalog_table.aws_glue_catalog_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |
| [aws_glue_schema.aws_glue_schema](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_schema) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_s3_input](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.lambda_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.aws_s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.aws_s3_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.archive_info_to_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.archive_to_s3_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [local_file.lambda_info_to_s3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.lambda_to_s3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.query_to_s3](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [archive_file.archive_info_to_s3](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.archive_to_s3](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.allow_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_s3_input](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws"></a> [aws](#input\_aws) | AWS related information and credentials | <pre>object({<br>    region     = string<br>    access_key = string<br>    secret_key = string<br>  })</pre> | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the data product | `string` | n/a | yes |
| <a name="input_input"></a> [input](#input\_input) | List of S3 buckets of other data products which should be used as input | <pre>list(object({<br>    source     = string<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the data product | `string` | n/a | yes |
| <a name="input_output"></a> [output](#input\_output) | format: Output format of this data product (e.g. PARQUET)<br>schema: Path to the JSON schema file which describes the output of this data product | <pre>object({<br>    format     = string<br>    schema     = string<br>  })</pre> | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The schedule expression to pass to the EventBridge event rule. Format: Minutes \| Hours \| Day of month \| Month \| Day of week \| Year | `string` | `""` | no |
| <a name="input_transform"></a> [transform](#input\_transform) | Path to a SQL file, which should be used to transform the input data | <pre>object({<br>    query = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
