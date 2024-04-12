data "aws_iam_policy" "AWSKeys" {
  name = "aws-${var.organization}-keyAccessPolicy-RW"
}

data "aws_iam_role" "eks-iam-role" {
  name = "${var.organization}-eks-iam-role"
}

data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "cluster" {
 name        = "${var.cluster_name}"
 role_arn    = data.aws_iam_role.eks-iam-role.arn
 vpc_config {
  subnet_ids = concat(var.subnet_private_ids, var.subnet_public_ids)
 }
 tags = {
    environment = var.environment
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_iam_role" "workernodes" {
  name = "eks-${var.organization}-node-group-workernodes"
}

 resource "aws_eks_node_group" "worker-node-group-private" {
  cluster_name    = "${var.cluster_name}"
  node_group_name = "${var.cluster_name}-private-workernodes"
  node_role_arn   = data.aws_iam_role.workernodes.arn
  subnet_ids      = concat(var.subnet_private_ids, var.subnet_public_ids)
 
  capacity_type   = "ON_DEMAND"
  instance_types  = var.instance_types
 
  scaling_config {
   desired_size    = 2
   max_size        = 100
   min_size        = 1
  }

  update_config {
    max_unavailable = 1
  }
  
  tags = {
    environment = var.environment
  }

  depends_on = [
    aws_eks_cluster.cluster
  ]
 }

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
  depends_on = [
    aws_eks_cluster.cluster
  ]
}

data "tls_certificate" "eks"{
 url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name   = "aws-${var.organization}-LoadbalancerPolicy-RW"
}

data "aws_iam_policy" "AWSVPCControllerIAMPolicy" {
  name   = "aws-${var.organization}-VPCGroupPolicy-RW"
}

data "aws_iam_policy" "AWSEksIamPolicy" {
   name           = "aws-${var.organization}-eks-RW"
}

data "aws_iam_policy" "AWSEcrGroupPolicy" {
   name           = "aws-${var.organization}-EcrGroupPolicy-RW"
}

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com", " https://gitlab.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "AWSLoadBalancerCtrlerIamRole"
  provider_url                  =  replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  provider_urls                 = [replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")]
  role_policy_arns              = [data.aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn,
                                   data.aws_iam_policy.AWSVPCControllerIAMPolicy.arn,
                                   data.aws_iam_policy.AWSKeys.arn,
                                   data.aws_iam_policy.AWSEksIamPolicy.arn,
                                   data.aws_iam_policy.AWSEcrGroupPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller",
                                   "system:serviceaccount:${var.namespace}:aws-load-balancer-controller"]

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Role = "role-with-oidc-self-assume"
  }
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "${var.namespace}"
    annotations = {
      "eks.amazonaws.com/role-arn"   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSLoadBalancerCtrlerIamRole"
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "${data.aws_caller_identity.current.account_id}"
    }
  }
}


resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "${data.aws_caller_identity.current.account_id}"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
      "serviceaccounts",
      "clusterroles"
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
      "serviceaccounts",
      "clusterroles"
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "aws-load-balancer-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/managed-by" = "${data.aws_caller_identity.current.user_id}"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata[0].name
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}
