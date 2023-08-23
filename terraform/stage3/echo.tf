resource "kubernetes_manifest" "echo" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name       = "echo"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }

    spec = {
      project = "default"
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }

      source = {
        repoURL        = "https://github.com/yarsiemanym/echo.git"
        targetRevision = "HEAD"
        path           = "manifests"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "echo"
      }
    }
  }
}
