provider "vault" {
  address          = var.VAULT_ADDR
  token            = var.CICD_VAULT_TOKEN
}

locals {
  workspace        = length(regexall("_",  var.ENV_WORKSPACE))>0?split("_", var.ENV_WORKSPACE)[1]:var.ENV_WORKSPACE
  access_key_index = join("_", ["AWS_ACCESS_KEY", var.ACCOUNT, var.PROFILE, local.workspace])
  secret_key_index = join("_", ["AWS_SECRET_KEY", var.ACCOUNT, var.PROFILE, local.workspace])
}

data   "vault_generic_secret" "aws_environment" {
  namespace        = local.workspace
  path             = lower("secret/aws/environment")
}

data   "vault_generic_secret" "aws_auth" {
  namespace        = local.workspace
  path             = lower(join("/", ["secret/aws", join("_", [var.ACCOUNT, "administrators"])]))
}


locals {
    env            = jsondecode(data.vault_generic_secret.aws_environment.data_json)
    namespace      = local.workspace
    region         = data.vault_generic_secret.aws_environment.data["vpc_region"]
    access_key     = data.vault_generic_secret.aws_auth.data[local.access_key_index]
    secret_key     = data.vault_generic_secret.aws_auth.data[local.secret_key_index]
}


provider "aws" {
    region         = local.region
    access_key     = local.access_key
    secret_key     = local.secret_key
}

module "_VPC_" {
    source                = "./modules/aws/network/vpc"
    vpc_azs               = local.env["azs"]
    vpc_name              = local.env["vpc_name"]
    vpc_cidr_block        = local.env["vpc_cidr_block"]
    vpc_public_subnet     = local.env["vpc_public_subnet"]
    vpc_app_subnet        = local.env["vpc_app_subnet"]
    vpc_db_subnet         = local.env["vpc_db_subnet"]
    environment           = local.env["environment"]
    cluster_name          = local.env["clustername"]
}


module "_S3_" {
    source                = "./modules/aws/global/s3"
    environment           = local.env["environment"]
    bucket_name           = "s3${var.PROJECT_NAME}${local.env["environment"]}"
}

module "_S3_LB_LOGS_" {
    source                = "./modules/aws/global/s3"
    environment           = local.env["environment"]
    bucket_name           = "s3_lb_logs_${var.PROJECT_NAME}${local.env["environment"]}"
}

module "_LB_" {
    source                = "./modules/aws/loadbalancer"
    enable                = false
    environment           = local.env["environment"]
    vpc_id                = module._VPC_.aws_vpc_id
    s3_bucket_log_id      = module._S3_LB_LOGS_.s3_bucket_id
    public_subnet_azs     = module._VPC_.vpc_public_subnet_azs[*]
}

module "_EKS_" {
    source                  = "./modules/aws/eks"
    account                 = var.ACCOUNT
    profile                 = var.PROFILE
    organization            = var.ACCOUNT
    environment             = local.env["environment"]
    aws_region              = local.env["vpc_region"]
    
    vpc_id                  = module._VPC_.aws_vpc_id
    subnet_private_ids      = module._VPC_.vpc_app_subnet_azs[*]
    subnet_public_ids       = module._VPC_.vpc_public_subnet_azs[*]

    cluster_name            = local.env["clustername"]
    namespace               = local.env["namespace"]
    instance_types          = local.env["node_pool_type"]
    
    enable_gitlab_ks8       = false
    enable_cert_manager_ks8 = false
    enable_fluentbit        = false
}

module "_REGISTRY_" {
    source                  = "./modules/aws/global/ecr"
    organization            = var.ORGANIZATION
    repos                   = local.env["registry"]
    depends_on = [
    module._EKS_
 ]
}
