module "main" {
  source        = "./modules"
  kube_config   = var.kube_config
  env           = var.env
  domain_name   = var.domain_name
  argocd_server = var.argocd_server
}