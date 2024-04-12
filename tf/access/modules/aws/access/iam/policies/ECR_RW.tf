data "aws_iam_policy_document" "ecr_RW" {
  statement {
    actions = [
		"ecr:CreateRepository",
		"ecr:DescribeRepositories",
		"ecr:ListTagsForResource",
		"ecr:DeleteRepository",
    "ecr:GetAuthorizationToken",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload",
    "ecr:PutImage",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability",
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload",
    "ecr:DescribeRepositories",
    "ecr:DescribeImages",
    "ecr:GetRepositoryPolicy",
    "ecr:ListImages",
    "ecr:DeleteRepository",
    "ecr:BatchDeleteImage",
    "ecr:SetRepositoryPolicy",
    "ecr:DeleteRepositoryPolicy"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_RW" {
  name   = "aws-${var.organization}-EcrGroupPolicy-RW"
  path   = "/"
  policy = data.aws_iam_policy_document.ecr_RW.json
}
