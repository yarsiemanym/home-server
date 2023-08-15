resource "kubernetes_manifest" "self_signed_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "self-signed-cluster-issuer"
    }

    spec = {
      selfSigned = {}
    }
  }
}

resource "kubernetes_manifest" "ca_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "ca-cert"
      namespace = "cert-manager"
    }

    spec = {
      isCA        = true
      secretName  = "ca-cert"
      duration    = "8760h0m0s" // 1 year
      renewBefore = "720h0m0s"  // 1 month
      dnsNames    = [var.domain]

      privateKey = {
        algorithm = "RSA"
        size      = 4098
      }

      issuerRef = {
        name  = kubernetes_manifest.self_signed_issuer.manifest.metadata.name
        kind  = kubernetes_manifest.self_signed_issuer.manifest.kind
        group = "cert-manager.io"
      }
    }
  }
}

resource "kubernetes_manifest" "ca_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "ca-cluster-issuer"
    }

    spec = {
      ca = {
        secretName = kubernetes_manifest.ca_cert.manifest.spec.secretName
      }
    }
  }
}
