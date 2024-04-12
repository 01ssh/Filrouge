data "aws_iam_policy_document" "groupPolicy_RW" {
  statement {
    actions = [
		"iam:GetUser",
		"iam:UpdateUser",
		"iam:AddUserToGroup",
		"iam:GetGroup",
    "iam:DeleteGroup",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:DeleteLoginProfile",
		"iam:RemoveUserFromGroup",
		"iam:RemoveUserFromGroup",
    "iam:GetOpenIDConnectProvider",
    "iam:ListOpenIDConnectProviders",
    "iam:DeleteOpenIDConnectProvider",
    "iam:ListEntitiesForPolicy",
    "iam:ListGroupsForUser",
    "iam:GetLoginProfile",
    "iam:ListAccessKeys",
    "iam:ListUsers",
    "iam:DetachGroupPolicy",
    "iam:DeletePolicy",
    "iam:DeleteLoginProfile",
    "iam:DeleteAccessKey",
    "iam:ListPolicyVersions",
    "iam:ListSSHPublicKeys",
    "cloudwatch:DescribeAlarms",
    "tag:GetResources",
    "iam:TagRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "groupPolicy_RW" {
   name        = "aws-${var.organization}-GroupPolicy-RW"
   description = "aws-${var.organization}-GroupPolicy-RW"
   policy      = data.aws_iam_policy_document.groupPolicy_RW.json
}

