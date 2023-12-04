resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.8.3"
  namespace  = "kube-system"
  timeout    = "1200"
  values     = [
    templatefile("${path.module}/values-${var.env}.yaml", {})
  ]
  wait = true
}
