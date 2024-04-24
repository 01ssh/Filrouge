data "aws_iam_policy_document" "eks_RW" {
  statement {
    actions = [
	    "EKS:CreateCluster",
      "EKS:DescribeCluster",
      "EKS:DeleteCluster",
      "EKS:CreateNodegroup",
      "EKS:ListFargateProfiles",
      "EKS:DescribeNodegroup",
      "EKS:AccessPolicy",
      "EKS:ListNodegroups",
      "EKS:ListUpdates",
      "EKS:AccessKubernetesApi",
      "EKS:ListAddons",
      "EKS:DescribeCluster",
      "EKS:DeleteNodegroup",
      "EKS:DescribeAddonVersions",
      "EKS:DescribeUpdate",
      "EKS:ListClusters",
      "EKS:ListIdentityProviderConfigs",
      "EKS:UpdateClusterConfig",
      "EKS:UpdateNodegroupConfig",
      "EKS:ListPodIdentityAssociation",
      "EKS:TagResource",
      "EKS:UntagResource",
      "aps:ListScrapers",
      "iam:ListRoles",
      "EKS:DeleteCluster",
      "EKS:CreateAddon",
      "EKS:DescribeAddon",
      "EKS:DeleteAddon"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "eks-iam-role" {
name = "${var.organization}-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version" : "2012-10-17",
 "Statement" : [
  {
   "Effect" : "Allow",
   "Principal" : {
    "Service" : ["eks.amazonaws.com",
                 "ec2.amazonaws.com",
                 "sts.amazonaws.com"]
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_policy" "eks_RW" {
   name        = "aws-${var.organization}-eks-RW"
   description = "aws-${var.organization}-eks-RW"
   policy      = data.aws_iam_policy_document.eks_RW.json
}

resource "aws_iam_role" "workernodes" {
  name = "eks-${var.organization}-node-group-workernodes"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role    = aws_iam_role.workernodes.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }