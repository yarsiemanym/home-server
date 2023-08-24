resource "kubernetes_manifest" "acme_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "acme-cluster-issuer"
    }

    spec = {
      acme = {
        email = var.operator_email_address
        //server = "https://acme-v02.api.letsencrypt.org/directory"
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          //name = "letsencrypt-prod"
          name = "letsencrypt-staging"
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
