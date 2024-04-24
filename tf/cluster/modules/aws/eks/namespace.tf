
resource "kubernetes_namespace" "namespace" {
  for_each  =  nonsensitive(var.namespace["namespaces"])
  metadata {
    name    = each.value
  }
  depends_on = [
    aws_eks_cluster.cluster
  ]
}