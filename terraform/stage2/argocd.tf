resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    templatefile("./argocd.yaml", {
      DOMAIN          = var.domain
      TLS_SECRET_NAME = kubernetes_manifest.argocd_cert.manifest.spec.secretName
      }
  )]
}

resource "kubernetes_manifest" "argocd_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "argocd-cert"
      namespace = kubernetes_namespace.argocd.metadata.0.name
    }

    spec = {
      secretName = "argocd-cert"
      commonName = "argocd.${var.domain}"
      dnsNames   = ["argocd.${var.domain}"]

      subject = {
        organizations       = ["Home"]
        organizationalUnits = ["IT"]
      }

      issuerRef = {
        name  = kubernetes_manifest.acme_cluster_issuer.manifest.metadata.name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }

      privateKey = {
        algorithm = "RSA"
        size      = 4096
      }
    }
  }
}
