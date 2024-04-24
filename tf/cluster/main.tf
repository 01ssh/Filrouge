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
    env                     = jsondecode(data.vault_generic_secret.aws_environment.data_json)
    region                  = data.vault_generic_secret.aws_environment.data["vpc_region"]
    namespace               = local.workspace
    access_key              = data.vault_generic_secret.aws_auth.data[local.access_key_index]
    secret_key              = data.vault_generic_secret.aws_auth.data[local.secret_key_index]
    monitoring              = data.vault_generic_secret.aws_environment.data["monitoring"]
}


provider "aws" {
    region                  = local.region
    access_key              = local.access_key
    secret_key              = local.secret_key
}

module "_VPC_" {
    source                  = "./modules/aws/network/vpc"
    environment             = local.env["environment"]
    cluster_name            = local.env["clustername"]
    vpc_azs                 = local.env["azs"]
    vpc_name                = local.env["vpc_name"]
    vpc_cidr_block          = local.env["vpc_cidr_block"]
    vpc_public_subnet       = local.env["vpc_public_subnet"]
    vpc_app_subnet          = local.env["vpc_app_subnet"]
    vpc_db_subnet           = local.env["vpc_db_subnet"]
}


module "_S3_" {
    source                  = "./modules/aws/global/s3"
    count                   = length(local.env["s3"])
    bucket_name             = join("-", [local.env["s3"][count.index], "storage"])
    environment             = local.env["environment"]
}

module "_LB_" {
    source                  = "./modules/aws/loadbalancer"
    enable                  = false
    environment             = local.env["environment"]
    vpc_id                  = module._VPC_.aws_vpc_id
    s3_bucket_log_id        = module._S3_[1].s3_bucket_id
    public_subnet_azs       = module._VPC_.vpc_public_subnet_azs[*]
    depends_on = [
    module._S3_
 ]
}

module "_EKS_" {
    source                  = "./modules/aws/eks"
    organization            = var.ACCOUNT
    account                 = var.ACCOUNT
    profile                 = var.PROFILE
    secretAccessKey         = local.secret_key
    accessKeyId             = local.access_key
    environment             = local.env["environment"]
    region                  = local.env["vpc_region"]
    
    vpcid                   = module._VPC_.aws_vpc_id
    subnet_private_ids      = module._VPC_.vpc_app_subnet_azs[*]
    subnet_public_ids       = module._VPC_.vpc_public_subnet_azs[*]

    clustername             = local.env["clustername"]
    namespace               = local.env["namespace"]
    instance_types          = local.env["node_pool_type"]
    
    
    enable_gitlab_agent     = false
    enable_monitoring       = true
    enable_management       = true
    monitoring              = local.env["monitoring"]
}

module "_REGISTRY_" {
    source                  = "./modules/aws/global/ecr"
    organization            = var.ORGANIZATION
    repos                   = local.env["registry"]
    depends_on = [
    module._EKS_
 ]
}
