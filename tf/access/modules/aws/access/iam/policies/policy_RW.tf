data "aws_iam_policy_document" "operationonPolicy_RW" {
  statement {
    actions = [
		"iam:CreateRole",
    "iam:GetRole",
    "iam:ListRolePolicies",
    "iam:ListAttachedRolePolicies",
    "iam:ListInstanceProfilesForRole",
    "iam:CreateServiceLinkedRole",
    "iam:DeleteRole",
    "iam:AttachRolePolicy",
    "iam:UpdateAssumeRolePolicy",
    "iam:PassRole",
    "iam:DetachRolePolicy",
    "iam:ListPolicies",
    "iam:CreateOpenIDConnectProvider",
    "iam:TagOpenIDConnectProvider"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "operationonPolicy_RW" {
   name        = "aws-${var.organization}-operationonPolicy-RW"
   description = "aws-${var.organization}-operationonPolicy-RW"
   policy      = data.aws_iam_policy_document.operationonPolicy_RW.json
}
