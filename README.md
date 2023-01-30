# terraform-datamesh-dataproduct-aws-athena

## Constraints

 * Read from one Kafka topic with exactly one message format
 * One SQL file as transformation

## Backlog

 * HTTP data product endpoint
 * Support multiple inputs (from S3, from existing data product, ...)
 * Kafka Connector as separate (independent) repository (t.b.d.)
 * Console I/O for reading passwords (use Terraform state)
 * Password console output as public key

## Data Product endpoint

GET https://example.com/dataproducts/shelf_warmers/

Response 200 OK

```
{
    
}
