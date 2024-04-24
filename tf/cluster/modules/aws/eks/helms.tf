data "aws_ecr_authorization_token" "token" {}

data "vault_generic_secret" "aws_gitlab_auth" {
  path = "secret/aws/gitlab"
}

resource "helm_release" "gitlab_agent" {
  count            = var.enable_gitlab_agent == true? 1 : 0
  name             = "gitlab-agent"
  provider         = helm.v3
  version          = "1.24.0"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  create_namespace = true
  namespace        = var.namespace["default"]

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
  namespace=var.namespace["default"]
  path = lower(join("/", ["secret/aws", join("_", [var.account, "administrators"])]))
}


 resource "helm_release" "alb_controller" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  provider   = helm.v3
  version    = "1.4.1"
  namespace  = var.namespace["default"]
  create_namespace = false
  atomic     = true
  timeout    = 300

  dynamic "set" {

    for_each = {
      "clusterSecretsPermissions.allowAllSecrets" = true
      "serviceAccount.create"     = false
      "clusterName"               = aws_eks_cluster.cluster.name
      "serviceAccount.name"       = kubernetes_service_account.this.metadata[0].name
      "region"                    = var.region
      "vpcId"                     = var.vpcid
      "hostNetwork"               = false
      "replicaCount"              = 2
      "enableCertManager"         = false
      "image.repository"          = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
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

 resource "helm_release" "prometheus" {
  count              = var.enable_monitoring == true? 1 : 0
  repository         = "https://prometheus-community.github.io/helm-charts"
  provider           = helm.v3
  name               = "prometheus"
  chart              = "prometheus"
  namespace          = var.namespace["namespaces"]["monitoring"]
  version            = "15.5.3"
  timeout            = 900
 }

 resource "helm_release" "grafana" {
  
  count                            = var.enable_monitoring == true? 1 : 0
  repository                       = "https://grafana.github.io/helm-charts"
  provider                         = helm.v3
  chart                            = "loki-stack"
  name                             = "loki"
  namespace                        = var.namespace["namespaces"]["monitoring"]
  version                          = "2.10.2"
  values                           = [file("${path.module}/charts/grafana/values.yaml")]
  timeout                          = 900

   dynamic "set" {
    for_each = {
      "grafana.rbac.pspEnabled"        = false
      "prometheus_svc"                 = "${helm_release.prometheus[0].name}-server"
      "admin_existing_secret"          = var.monitoring["grafana"]["admin"]
      "admin_user_key"                 = var.monitoring["grafana"]["adminuser"]
      "admin_password_key"             = var.monitoring["grafana"]["adminpassword"]
      "replicas"                       = var.monitoring["grafana"]["replicas"]
      "storage.s3.region"              = var.region
      "storage.s3.secretAccessKey"     = var.secretAccessKey
      "storage.s3.accessKeyId"         = var.accessKeyId
      "storage_config.aws.bucketnames" = join("-", ["loki-storage", data.aws_caller_identity.current.id])
      "storage.bucketnames.chunks"     = join("-", ["loki-storage", data.aws_caller_identity.current.id])
      "storage.bucketnames.ruler"      = join("-", ["loki-storage", data.aws_caller_identity.current.id])
      "storage.bucketnames.admin"      = join("-", ["loki-storage", data.aws_caller_identity.current.id])
      "storage.s3.s3"                  = join("-", ["s3://loki-storage", data.aws_caller_identity.current.id])
      "fluent-bit.enabled"             = true
      "grafana.enabled"                = true
      "promtail.enabled"               = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  set {
    name    = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value   = "arn:aws:iam::${data.aws_caller_identity.current.id}:role/${data.aws_iam_role.eks-iam-role.name}"
    type    = "string"
  } 
  depends_on = [
    helm_release.prometheus[0],
    helm_release.alb_controller
  ]
}

 resource "helm_release" "argo-cd" {
  count              = var.enable_management == true? 1 : 0
  repository         = "https://argoproj.github.io/argo-helm"
  provider           = helm.v3
  name               = "argo-cd"
  chart              = "argo-cd"
  namespace          = var.namespace["namespaces"]["argo-cd"]
  version            = "3.2.3"
  timeout            = 900
 }