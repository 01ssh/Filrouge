variable "group_name" {
  description = "group name policy to apply"
  type        = string
  default     = "" 
}


variable "region" {
  description = "region"
  type        = string
  default     = "eu-west-3" 
}

variable "organization" {
  description = "entity prefix"
  type        = string
  default     = "dst"
}

variable "arnaccount" {
  description = "arn account policy"
  type        = list
  default     = []
}

variable "shared_accounts" {
  type = list(string)
  default     = ["dst_admin_production",
                 "dst_admin_development",
                 "dst_admin_preprod"]
}