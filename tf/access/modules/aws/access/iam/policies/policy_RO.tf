data "aws_iam_policy_document" "operationonPolicy_RO" {
  statement {
    actions = [
	"iam:GetPolicy",
	"iam:ListPolicy",
        "iam:DescribePolicy",
        "iam:GetPolicyVersion"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "operationonPolicy_RO" {
   name        = "aws-${var.organization}-operationonPolicy-RO"
   description = "aws-${var.organization}-operationonPolicy-RO"
   policy      = data.aws_iam_policy_document.operationonPolicy_RO.json
}
