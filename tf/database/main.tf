

provider "vault" {
  address          = var.VAULT_ADDR
  token            = var.CICD_VAULT_TOKEN
}

locals {
  namespace        = length(regexall("_",  var.ENV_WORKSPACE))>0?split("_", var.ENV_WORKSPACE)[1]:var.ENV_WORKSPACE
  workspace        = length(regexall("_",  var.ENV_WORKSPACE))>0?split("_", var.ENV_WORKSPACE)[1]:var.ENV_WORKSPACE
  access_key_index = join("_", ["AWS_ACCESS_KEY", var.ACCOUNT, var.PROFILE, local.workspace])
  secret_key_index = join("_", ["AWS_SECRET_KEY", var.ACCOUNT, var.PROFILE, local.workspace])
}

data   "vault_generic_secret" "aws_db" {
  namespace        = local.namespace
  path             = lower(join("/", ["secret/aws", join("_", [var.ACCOUNT, "administrators_db"])]))
}

data   "vault_generic_secret" "aws_environment" {
  namespace        = local.namespace
  path             = lower("secret/aws/environment")
}

data   "vault_generic_secret" "aws_auth" {
  namespace        = local.namespace
  path             = lower(join("/", ["secret/aws", join("_", [var.ACCOUNT, "administrators"])]))
}


locals {
    env            = jsondecode(data.vault_generic_secret.aws_environment.data_json)
    region         = data.vault_generic_secret.aws_environment.data["vpc_region"]
    access_key     = data.vault_generic_secret.aws_auth.data[local.access_key_index]
    secret_key     = data.vault_generic_secret.aws_auth.data[local.secret_key_index]
    db_name        = var.MASTER_DB_AWSWNAME==""?data.vault_generic_secret.aws_db.data[join("_", ["AWS_DB_AURORA_NAME",var.ACCOUNT,"admin",local.workspace])]:var.MASTER_DB_AWSWNAME
    db_user        = var.MASTER_DB_USERNAME==""?data.vault_generic_secret.aws_db.data[join("_", ["AWS_DB_AURORA_USER",var.ACCOUNT,"admin",local.workspace])]:var.MASTER_DB_USERNAME
    db_password    = var.MASTER_DB_USERNAME==""?data.vault_generic_secret.aws_db.data[join("_", ["AWS_DB_AURORA_USER",var.ACCOUNT,"admin",local.workspace])]:var.MASTER_DB_USERNAME
}

provider "aws" {
    region         = local.region
    access_key     = local.access_key
    secret_key     = local.secret_key
}

data "aws_vpcs" "in_region" {
  filter {
    name   = "tag:environment"
    values = [local.namespace]
  }
}

data "aws_subnets" "db_subnets" {
  filter {
    name   = "tag:Name"
    values = ["*_db_subnet_*"]
  }
}

module "_DB_" {
    ACCOUNT                     = var.ACCOUNT
    manage_master_user_password = true
    create_db_subnet_group      = false
    source                      = "./modules/aws/aurora-rds"
    vpc_id                      = data.aws_vpcs.in_region.ids[0]
    aws_region                  = local.env["vpc_region"]
    
    private_subnets_ids         = data.aws_subnets.db_subnets.ids
    private_subnets_cidr        = local.env["vpc_db_subnet"]
    vpc_cidr_blocks             = concat(local.env["vpc_db_subnet"], 
                                    local.env["vpc_app_subnet"],
                                    local.env["vpc_public_subnet"])

    availability_zones          = local.env["azs"]
    database_name               = local.db_name
    master_username             = local.db_user
    master_password             = local.db_password
    namespace                   = local.env["namespace"]
    cluster_identifier          = local.env["db_cluster_name"]
    engine_version              = local.env["db_version"]
    instance_class              = local.env["db_class_storage"]
    engine                      = local.env["db_engine"]
}
