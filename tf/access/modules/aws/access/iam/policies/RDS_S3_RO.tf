data "aws_iam_policy_document" "rds_s3_RO" {
  statement {
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBSnapshots",
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBEngineVersions",
      "rds:DescribeDBParameterGroups",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DescribeDBParameters",
      "rds:DescribeEventSubscriptions",
      "rds:ListTagsForResource",
      "rds:DescribeDBSecurityGroups",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBSubnetGroup",
      "rds:ListTagsForResource",
      "S3:HeadBucket",
      "S3:ListBucket",
      "S3:GetBucketPolicy",
      "S3:GetBucketAcl",
      "S3:GetBucket*",
      "S3:GetBucketVersioning",
      "S3:GetBucketAccelerateConfiguration",
      "rds:DescribeDBCluster*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:List*",
      "kms:Get*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rds_s3_RO" {
  name   = "aws-${var.organization}-${var.group_name}RDS_S3_Policy-RO"
  path   = "/"
  policy = data.aws_iam_policy_document.rds_s3_RO.json
}
