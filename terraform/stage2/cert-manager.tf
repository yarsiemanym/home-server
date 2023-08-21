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
        name  = kubernetes_manifest.acme_cluster_issuer.manifest.metadata.name
        kind  = kubernetes_manifest.acme_cluster_issuer.manifest.kind
        group = "cert-manager.io"
      }

      privateKey = {
        algorithm = "RSA"
        size      = 4096
      }

      secretTemplate = {
        annotations = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = true
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = "default,observability,argocd,pihole"
          "reflector.v1.k8s.emberstack.com/reflection-auto-enabled"       = true
          "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces"    = "default,observability,argocd,pihole"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "acme_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "acme-cluster-issuer"
    }

    spec = {
      acme = {
        email  = var.operator_email_address
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            selector = {
              dnsZones = [var.domain]
            }
            dns01 = {
              route53 = {
                region      = var.aws_region
                accessKeyID = var.aws_access_key_id
                secretAccessKeySecretRef = {
                  name = kubernetes_secret.aws_secret_access_key.metadata.0.name
                  key  = "key"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_secret" "aws_secret_access_key" {
  metadata {
    name      = "aws-secret-access-key"
    namespace = "cert-manager"
  }

  data = {
    key = var.aws_secret_access_key
  }
}
