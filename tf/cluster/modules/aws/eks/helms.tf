data "aws_ecr_authorization_token" "token" {}

data "vault_generic_secret" "aws_gitlab_auth" {
  path = "secret/aws/gitlab"
}

resource "helm_release" "gitlab_agent" {
  count            = var.enable_gitlab_agent_ks8 == true? 1 : 0
  name             = "gitlab-agent"
  provider         = helm.v3
  version          = "1.24.0"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  create_namespace = true
  namespace        = var.namespace

  set {
     name  = "replicas"
     value = 2
  }

  set {
    name  = "config.kasAddress"
    value = data.vault_generic_secret.aws_gitlab_auth.data["K8S_GITLAB_KASADDR"]
  }

  set {
    name  = "config.token"
    value = data.vault_generic_secret.aws_gitlab_auth.data["K8S_GITLAB_TOKEN"]
  }
 }

data "vault_generic_secret" "aws_auth" {
  namespace=var.namespace
  path = lower(join("/", ["secret/aws", join("_", [var.account, "administrators"])]))
}

 resource "helm_release" "cert_manager" {
  count            = var.enable_cert_manager_ks8 == true? 1 : 0
  name             = "cert-manager"
  provider         = helm.v3
  version          = "1.14.4"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true
  namespace        = "cert-manager"

  set {
     name  = "installCRDs"
     value = true
  }
    depends_on = [
    aws_eks_node_group.worker-node-group-private
  ]
 }


 resource "helm_release" "alb_controller" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  provider   = helm.v3
  version    = "1.4.1"
  namespace  = "${var.namespace}"
  create_namespace = false
  atomic     = true
  timeout    = 300

  dynamic "set" {

    for_each = {
      "clusterSecretsPermissions.allowAllSecrets" = true
      "serviceAccount.create"     = false
      "clusterName"               = aws_eks_cluster.cluster.name
      "serviceAccount.name"       = kubernetes_service_account.this.metadata[0].name
      "region"                    = var.aws_region
      "vpcId"                     = var.vpc_id
      "hostNetwork"               = false
      "replicaCount"              = 2
      "enableCertManager"         = false
      "image.repository"          = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
      "meta.helm.sh/release-name" = "aws-load-balancer-controller"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.chart_env_overrides
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    aws_eks_node_group.worker-node-group-private
  ]
}
