data "aws_iam_policy_document" "vpcPolicy_RW" {
  statement {
    actions = [
                "ec2:CreateVpc",
				"ec2:CreateTags",
				"ec2:DescribeVpcs",
				"ec2:DescribeVpcAttribute",
				"ec2:DeleteVpc",
				"ec2:CreateRouteTable",
				"ec2:DescribeRouteTables",
				"ec2:CreateSubnet",
				"ec2:DescribeSubnets",
				"ec2:DescribeNetworkInterfaces",
				"ec2:DeleteSubnet",
				"ec2:ModifySubnetAttribute",
				"ec2:CreateNatGateway",
				"ec2:DescribeNatGateways",
				"ec2:CreateInternetGateway",
				"ec2:AttachInternetGateway",
				"ec2:DescribeInternetGateways",
				"ec2:DeleteRouteTable",
				"ec2:AssociateRouteTable",
				"ec2:DeleteNatGateway",
				"ec2:DeleteInternetGateway",
				"ec2:CreateRoute",
				"ec2:DisassociateRouteTable",
				"ec2:DeleteRoute",
				"ec2:DisassociateAddress",
				"ec2:DetachInternetGateway",
				"ec2:AllocateAddress",
				"ec2:ReleaseAddress",
				"ec2:GetSubnetCidrReservations",
				"ec2:Describe*",
				"ec2:DeleteSecurityGroup",
				"ec2:RevokeSecurityGroupEgress",
				"ec2:AuthorizeSecurityGroupEgress",
				"ec2:DescribeAvailabilityZones",
				"ec2:DeleteNetworkInterface",
				"ec2:DetachNetworkInterface",
				"ec2:ModifyVpcAttribute",
				"ec2:ReplaceRouteTableAssociation",
				"autoscaling:DescribeAutoScalingGroups",
				"ec2:DeleteTags",
				"route53:*",
				"route53domains:*"

    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "route53:*",
      "route53domains:*",
      "cloudfront:ListDistributions",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticbeanstalk:DescribeEnvironments",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketWebsite",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRegions",
      "sns:ListTopics",
      "sns:ListSubscriptionsByTopic",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
	  "apigateway:GET"
    ]
    effect    = "Allow"
    resources = ["arn:aws:apigateway:*::/domainnames"]
  }
}

resource "aws_iam_policy" "vpcPolicy_RW" {
  name   = "aws-${var.organization}-${var.group_name}VPCGroupPolicy-RW"
  path   = "/"
  policy = data.aws_iam_policy_document.vpcPolicy_RW.json
}