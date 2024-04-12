data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_iam_policy_document" "keyAccess_RW" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = var.arnaccount
  }
  statement {
    actions = ["kms:CreateKey"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "keyAccess_RW" {
   name        = "aws-${var.organization}-keyAccessPolicy-RW"
   description = "aws-${var.organization}-keyAccessPolicy-RW"
   policy      = data.aws_iam_policy_document.keyAccess_RW.json
}
