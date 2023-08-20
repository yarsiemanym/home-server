resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

   set {
    name  = "configs.params.server\\.insecure"
    value = true
  }
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd"
    namespace = "argocd"
  }

  spec {
    tls {
      hosts       = ["*.${var.domain}"]
      secret_name = kubernetes_manifest.wildcard_cert.manifest.metadata.name
    }
    rule {
      host = "argocd.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}