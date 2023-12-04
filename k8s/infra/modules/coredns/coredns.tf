resource "helm_release" "coredns" {
  name       = "coredns"
  chart      = "coredns"
  repository = "https://coredns.github.io/helm"
  version    = "1.28.1"
  namespace  = "kube-system"
  timeout    = "1200"
  values     = [templatefile("${path.module}/values-${var.env}.yaml", {})]
  wait       = true
}
