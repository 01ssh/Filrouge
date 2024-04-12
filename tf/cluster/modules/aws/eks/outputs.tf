output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "clustername" {
  value = aws_eks_cluster.cluster.name
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority.0.data
}

output "identity-oidc-issuer" {
  value = "${aws_eks_cluster.cluster.identity.0.oidc.0.issuer}"
}