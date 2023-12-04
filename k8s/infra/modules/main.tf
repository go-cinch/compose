provider "kubernetes" {
  config_path = var.kube_config
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config
  }
}

provider "argocd" {
  server_addr = var.argocd_server
  username    = "admin"
  password    = "admin"
  context     = var.kube_config
}

module "metrics" {
  source = "./metrics"
  env    = var.env
}

module "coredns" {
  depends_on = [module.metrics]
  source     = "./coredns"
  env        = var.env
}

module "ingress" {
  depends_on = [module.coredns]
  source     = "./ingress"
  env        = var.env
}

module "argocd" {
  depends_on = [module.ingress]

  source        = "./argocd"
  env           = var.env
  argocd_server = var.argocd_server
}