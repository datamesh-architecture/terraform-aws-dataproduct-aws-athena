# Data Mesh Terraform module "AWS Athena"

This Terraform module provisions the necessary services to provide a data product on AWS.

![](assets/images/overview.png)

## Services

* AWS S3
* AWS Athena
* AWS Glue
* AWS Lambda

## Usage

```hcl
module my_data_product {
  source = "git@github.com:datamesh-architecture/terraform-datamesh-dataproduct-aws-athena.git"

  domain   = "<data_product_domain>"
  name     = "<data_product_name>"
  schedule = "0 0 * * ? *" # Run at 00:00 am (UTC) every day

  input = [
    {
      source = "<data_product_endpoint>"
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

Examples, how to use this module, can be found in a separate [GitHub repository](https://github.com/datamesh-architecture/terraform-datamesh-dataproduct-examples).

## Requirements

| Name                                                                      | Version    |
|---------------------------------------------------------------------------|------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7   |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 4.0     |

## Providers

| Name                                                                | Version   |
|---------------------------------------------------------------------|-----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                   | >= 4.0    |

## Authors

Module is maintained by []().

## License

MIT License Licensed. See [LICENSE](https://github.com/datamesh-architecture/terraform-datamesh-dataproduct-aws-athena/blob/main/LICENSE) for full details.
