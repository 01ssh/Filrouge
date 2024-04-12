data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3store" {
  bucket	= replace(lower(join("_", [var.bucket_name, data.aws_caller_identity.current.account_id])), "_", "")
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_s3_bucket_versioning" "s3store" {
  bucket  = aws_s3_bucket.s3store.id

  versioning_configuration  {
    status = "Enabled"
  }
}