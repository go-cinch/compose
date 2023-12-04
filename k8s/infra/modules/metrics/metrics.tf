resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  version    = "3.11.0"
  namespace  = "kube-system"
  timeout    = "1200"
  values     = [
    templatefile("${path.module}/values-${var.env}.yaml", {})
  ]
  wait = true
}
