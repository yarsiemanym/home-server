resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }
}
