variable "environment" {
default = ""
description = "The environment which to fetch the configuration for."
type = string
}

variable "bucket_name" {
  description = "S3 registry bucket name"
  default = "registry-bucket"
}