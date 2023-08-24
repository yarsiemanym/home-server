resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "observability" {
  name       = "observability"
  namespace  = kubernetes_namespace.observability.metadata.0.name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    templatefile("./observability.yaml", {
      ADMIN_PASSWORD  = var.grafana_admin_password
      DOMAIN          = var.domain
      TLS_SECRET_NAME = kubernetes_manifest.grafana_cert.manifest.spec.secretName
      }
  )]
}

resource "kubernetes_manifest" "grafana_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "grafana-cert"
      namespace = kubernetes_namespace.observability.metadata.0.name
    }

    spec = {
      secretName = "grafana-cert"
      commonName = "grafana.${var.domain}"
      dnsNames   = ["grafana.${var.domain}"]

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
