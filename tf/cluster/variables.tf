variable "PROJECT_NAME" {
default     = "WORDPRESS"
description = "The environment which to fetch the configuration for."
type = string
}

variable "VAULT_ADDR" {
default     = "https://aws-wordpress-vault-cluster-public-vault-04cc1d86.d4f84486.z1.hashicorp.cloud:8200"
description = "Hashicorp Vault Token"
type = string
}

#token
variable "CICD_VAULT_TOKEN" {
default     = "hvs.CAESIBfnDOIOxeuJ0Jzkrhv6eFlwX0V0OISdBMzuO09xcz4ZGigKImh2cy40SEpOTm1XUUpKeVpBcVJHYkhyQ0NTWWQuYkhudmsQqvYR"
description = "Hashicorp Vault Token"
type = string
}

variable "ACCOUNT" {
default     = "terraform"
description = "Hashicorp IO organisation name to provide"
type = string
}


variable "ORGANIZATION" {
default     = "SOLCOMPUTING"
description = "Hashicorp IO organisation name to provide"
type = string
}

variable "PROFILE" {
default     = "admin"
description = "Hashicorp IO organisation name to provide"
type = string
}

variable "ENV_WORKSPACE" {
default     = "development"
description = "ENV_WORKSPACE"
type = string
}
