data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3store" {
  bucket	= join("-", [var.bucket_name, data.aws_caller_identity.current.id])
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
      name = var.bucket_name
      account_id = data.aws_caller_identity.current.account_id
  }
}


resource "aws_s3_bucket_versioning" "s3store" {
  bucket  = aws_s3_bucket.s3store.id

  versioning_configuration  {
    status = "Enabled"
  }
}