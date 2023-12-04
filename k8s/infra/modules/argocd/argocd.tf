resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  # Wait for the Kubernetes namespace to be created
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.35.0"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  timeout    = "1200"
  values     = [
    templatefile("${path.module}/values-${var.env}.yaml", {
      server_insecure: true
      admin_enabled: true
      argocd_server: var.argocd_server
    })
  ]
  set {
    name  = "service.type"
    value = "ClusterIp"
  }
  wait = true
}

# kubectl get secrets -n argocd
resource "kubernetes_secret" "argocd-ingress-tls" {
  depends_on = [kubernetes_namespace.argocd]
  
  type = "kubernetes.io/tls"
  metadata {
    name      = "argocd-ingress-tls"
    namespace = "argocd"
  }
  data = {
    "tls.crt" = file("${path.module}/certs/server-${var.env}.pem")
    "tls.key" = file("${path.module}/certs/server-${var.env}.key")
  }
}

resource "kubernetes_ingress_v1" "argocd-ingress" {
  depends_on = [kubernetes_secret.argocd-ingress-tls]

  metadata {
    name        = "argocd-ingress"
    namespace   = "argocd"
    annotations = {
      "ingress.kubernetes.io/force-ssl-redirect": "true"
    }
  }
  spec {
    tls {
      hosts       = [var.argocd_server]
      secret_name = "argocd-ingress-tls"
    }
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = "argocd-server"
        port {
          number = 80
        }
      }
    }
    rule {
      host = var.argocd_server
      http {
        path {
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
  wait_for_load_balancer = false
}
