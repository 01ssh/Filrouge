variable "environment" {
default = "development"
description = "default environment"
type = string
}

variable "public_subnet_azs" {
 default = [""]
 description = "default environment"
 type = list(string)
}

variable "vpc_id" {
 default = ""
 description = "VPC ID"
 type = string
}

variable "s3_bucket_log_id" {
 default = ""
 description = "S3 LB Logs ID"
 type = string
}

variable "enable" {
 default = false
 type = bool
}