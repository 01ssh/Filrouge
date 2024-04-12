variable "ACCOUNT" {
description = "Hashicorp IO organisation name to provide"
type = string
}

variable "ENV_WORKSPACE" {
default     = "development"
description = "ENV_WORKSPACE"
type = string
}


variable "MASTER_DB_AWSWNAME" {
   type        = string
   default     = ""
}

variable "MASTER_DB_USERNAME" {
   type        = string
   default     = ""
}

variable "MASTER_DB_PASSWORD" {
   type        = string
   default     = ""
}

variable "VAULT_ADDR" {
default     = "https://aws-wordpress-vault-cluster-public-vault-04cc1d86.d4f84486.z1.hashicorp.cloud:8200"
description = "Hashicorp Vault Token"
type = string
}

variable "CICD_VAULT_TOKEN" {
default     = "hvs.CAESIA3-vIRQsWyFMBSph6LkdmUKFhRTbZ7jzveuxLJyJqIbGicKImh2cy44eGNJZUl3QnowM094UmFiTTJhWmMxWUouZldpZ3cQsBk"
description = "Hashicorp Vault Token"
type = string
}

variable "PROFILE" {
default     = "admin"
description = "Hashicorp IO organisation name to provide"
type = string
}