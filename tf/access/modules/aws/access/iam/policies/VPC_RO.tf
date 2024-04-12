data "aws_iam_policy_document" "vpcPolicy_RO" {
  statement {
    actions = [
        		"ec2:CreateTags",
				"ec2:DescribeVpcs",
				"ec2:DescribeVpcAttribute",
				"ec2:DescribeRouteTables",
				"ec2:DescribeSubnets",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DescribeNatGateways",
				"ec2:DescribeInternetGateways",
				"ec2:DeleteRouteTable",
				"ec2:AllocateAddress",
				"ec2:ReleaseAddress",
				"ec2:GetSubnetCidrReservations",
				"ec2:DescribeNetworkAcls"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpcPolicy_RO" {
  name   = "aws-${var.organization}-${var.group_name}VPCGroupPolicy-RO"
  path   = "/"
  policy = data.aws_iam_policy_document.vpcPolicy_RO.json
}