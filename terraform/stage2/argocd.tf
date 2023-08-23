resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

  values = [
    templatefile("./argocd.yaml", {
      DOMAIN          = var.domain
      TLS_SECRET_NAME = kubernetes_manifest.wildcard_cert.manifest.spec.secretName
      }
  )]
}
