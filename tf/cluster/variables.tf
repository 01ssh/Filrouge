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
default     = "hvs.CAESIA9oJJw7HQVtzq3HWBgQyIRaymSZZ6dZTmZMIzXoLJCVGigKImh2cy5kTEFoY25XM01VRVBXWGsyWnB0OWFhT2EuYkhudmsQluMW"
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
