

variable "cluster_identifier" {
   type        = string
   default     = ""
}

variable "namespace" {
   type        = string
   default     = ""
}

variable "aws_region" {
   type        = string
   default     = ""
}

variable "vpc_id" {
   type        = string
   default     = ""
}

variable "vpc_cidr_blocks" {
}

variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet IDs used by database subnet group created"
  type        = list(string)
  default     = []
}


variable "availability_zones" {
  description = "List of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured, which will show as a difference requiring resource recreation next Terraform apply"
  type        = list(string)
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = null
}

variable "private_subnets_ids" {
  description = "private subnets cidr blocks"
  type        = list
  default     = []
}

variable "engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to `aurora`. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}


variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in"
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "(Required if domain is provided) The name of the IAM role to be used when making API calls to the Directory Service"
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Required unless `manage_master_user_password` is set to `true` or unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user. Required unless `snapshot_identifier` or `replication_source_identifier` is provided or unless a `global_cluster_identifier` is provided when the cluster is the secondary cluster of a global database"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "instance_class" {
  type        = string
  default     = null
}

variable "instances" {
  type        = map(object({}))
  default     = {
  }
}

variable "ACCOUNT" {
  type        = string
  default     = null
}


variable "private_subnets_cidr" {
  type        = list(string)
  default     = null
}


variable "manage_master_user_password" {
  type        = bool
  default     = false
}