variable "kube_config" {
  default = "~/.kube/config"
  type    = string
}
variable "env" {
  default = "dev"
  type    = string
}
variable "domain_name" {
  type = string
}
variable "argocd_server" {
  type = string
}
