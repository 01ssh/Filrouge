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

variable "CICD_VAULT_TOKEN" {
default     = "hvs.CAESILHVgxp2Ezn9ViMtb6syZLdHAlrZTcUSWylyuTJaeJWsGigKImh2cy50YXN4blgyNkxKa2xKMWhQTjh6b2tiZVIuYkhudmsQm_kV"
description = "Hashicorp Vault Token"
type = string
}

variable "ACCOUNT" {
default     = "SOLCOMPUTING"
description = "Hashicorp IO organisation name to provide"
type = string
}

variable "IAM_ROOT_ACCOUNT" {
default     = "student17_jan24_bootcamp_devops_services"
description = "IAM ACCOUNT"
type = string
}

variable "ENV_WORKSPACE" {
default     = ""
description = "ENV_WORKSPACE"
type = string
}