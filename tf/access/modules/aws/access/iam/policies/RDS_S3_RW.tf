data "aws_iam_policy_document" "rds_s3_RW" {
  statement {
    actions = [
      "rds:CreateDBInstance",
      "rds:DescribeDBInstances",
      "rds:ModifyDBInstance",
      "rds:DeleteDBInstance",
      "rds:CreateDBSnapshot",
      "rds:DescribeDBSnapshots",
      "rds:DeleteDBSnapshot",
      "rds:CreateDBCluster",
      "rds:DescribeDBClusters",
      "rds:ModifyDBCluster",
      "rds:DeleteDBCluster",
      "rds:CreateDBClusterSnapshot",
      "rds:DescribeDBClusterSnapshots",
      "rds:DeleteDBClusterSnapshot",
      "rds:RestoreDBClusterFromSnapshot",
      "rds:RestoreDBInstanceFromDBSnapshot",
      "rds:DescribeDBEngineVersions",
      "rds:DescribeDBParameterGroups",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DescribeDBParameters",
      "rds:ModifyDBParameterGroup",
      "rds:ModifyDBClusterParameterGroup",
      "rds:CreateDBParameterGroup",
      "rds:CreateDBClusterParameterGroup",
      "rds:DeleteDBParameterGroup",
      "rds:DeleteDBClusterParameterGroup",
      "rds:CopyDBSnapshot",
      "rds:CreateEventSubscription",
      "rds:DescribeEventSubscriptions",
      "rds:DeleteEventSubscription",
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:RemoveTagsFromResource",
      "rds:AuthorizeDBSecurityGroupIngress",
      "rds:RevokeDBSecurityGroupIngress",
      "rds:DescribeDBSecurityGroups",
      "rds:DescribeDBSubnetGroups",
      "rds:ModifyDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:CreateDBSubnetGroup",
      "rds:CreateDBClusterParameterGroup",
      "rds:Describe*",
      "s3:*",
      "kms:*",
      "secretsmanager:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rds_s3_RW" {
  name   = "aws-${var.organization}-${var.group_name}RDS_s3_Policy-RW"
  path   = "/"
  policy = data.aws_iam_policy_document.rds_s3_RW.json
}