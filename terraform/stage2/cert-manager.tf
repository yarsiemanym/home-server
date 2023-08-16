resource "kubernetes_manifest" "self_signed_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "self-signed"
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
      isCA       = true
      secretName = "ca-cert"
      commonName = var.domain

      subject = {
        organizations       = ["Home"]
        organizationalUnits = ["IT"]
      }

      issuerRef = {
        name  = kubernetes_manifest.self_signed_cluster_issuer.manifest.metadata.name
        kind  = kubernetes_manifest.self_signed_cluster_issuer.manifest.kind
        group = "cert-manager.io"
      }

      privateKey = {
        algorithm = "RSA"
        size      = 4096
      }
    }
  }
}

resource "kubernetes_manifest" "ca_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "ca"
    }

    spec = {
      ca = {
        secretName = kubernetes_manifest.ca_cert.manifest.spec.secretName
      }
    }
  }
}

resource "kubernetes_manifest" "wildcard_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "wildcard-cert"
      namespace = "cert-manager"
    }

    spec = {
      secretName = "wildcard-cert"
      commonName = "*.${var.domain}"

      dnsNames = [
        var.domain,
        "*.${var.domain}"
      ]

      subject = {
        organizations       = ["Home"]
        organizationalUnits = ["IT"]
      }

      issuerRef = {
        name  = kubernetes_manifest.ca_cluster_issuer.manifest.metadata.name
        kind  = kubernetes_manifest.ca_cluster_issuer.manifest.kind
        group = "cert-manager.io"
      }

      privateKey = {
        algorithm = "RSA"
        size      = 4096
      }

      secretTemplate = {
        annotations = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = true
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = "default,observability,pihole"
          "reflector.v1.k8s.emberstack.com/reflection-auto-enabled"       = true
          "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces"    = "default,observability,pihole"
        }
      }
    }
  }
}
