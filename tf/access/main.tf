module "settings" {
    source             = "./modules/settings"
    environment        = "settings"
    profile            = lower(var.ACCOUNT)
}

module "IAM_admin_groups" {
    source             = "./modules/aws/access/iam/group_admin"
    iam_root           = module.settings.env.iam_root
    organization       = module.settings.env.group.organization
    group_name         = module.settings.env.group.group_name
    group_iam          = module.settings.env
    policies           = {}
}

module "IAM_policies" {
    source             = "./modules/aws/access/iam/policies"
    arnaccount         = [module.IAM_admin_groups.aws_iam_group_arn]
    organization       = module.settings.env.organization
    region             = module.settings.env.region
}


resource "aws_iam_policy_attachment" "group-attach-policies" {
  count                = length(module.IAM_policies.arn_policies_admin_RW)
  name                 = join("_", ["policygroup-attachment",
                                   module.settings.env.organization,
                                   module.settings.env.group.group_name,
                                   element(module.IAM_policies.arn_policies_admin_RW, count.index)])
  groups               = [module.IAM_admin_groups.aws_iam_group_name]
  policy_arn           = element(module.IAM_policies.arn_policies_admin_RW, count.index)
  depends_on           = [
    module.IAM_policies,
    module.IAM_admin_groups
  ]
}
