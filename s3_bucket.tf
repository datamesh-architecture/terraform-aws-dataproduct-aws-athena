resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = local.product_fqn
  force_destroy = true
}

resource "aws_s3_bucket_acl" "aws_s3_bucket_acl" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  acl    = "private"
}

resource "aws_kms_key" "aws_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aws_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
