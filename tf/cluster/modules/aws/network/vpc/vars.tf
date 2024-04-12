variable "environment" {
default = "development"
description = "VPC: default environment"
type = string
}


variable "vpc_azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["eu-west-1a"]
}

variable "vpc_cidr_block" {
default = "10.0.0.0/16"
description = "VPC: Region"
type = string
}

variable "vpc_region" {
default = ""
description = "VPC: Region"
type = string
}

variable "vpc_name" {
default = "wordpress"
description = "VPC: default"
type = string
}

variable "vpc_public_subnet" {
 type        = list(string)
 description = "Public public Subnet CIDR values"
 default     = []
}
 
variable "vpc_app_subnet" {
 type        = list(string)
 description = "Private app Subnet CIDR values"
 default     = []
}

variable "vpc_db_subnet" {
 type        = list(string)
 description = "Private db Subnet CIDR values"
 default     = []
}

variable "cluster_name" {
  type        = string
  default     = ""
}