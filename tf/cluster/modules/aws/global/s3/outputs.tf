output "s3_bucket_arn" {
  value = "${aws_s3_bucket.s3store.arn}"
}

output "s3_bucket_id" {
  value = "${aws_s3_bucket.s3store.id}"
}
