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
                region      = data.kubernetes_secret.aws.data.region
                accessKeyID = data.kubernetes_secret.aws.data.access_key_id
                secretAccessKeySecretRef = {
                  name      = data.kubernetes_secret.aws.metadata.0.name
                  namesapce = data.kubernetes_secret.aws.metadata.0.namespace
                  key       = "secret_access_key"
                }
              }
            }
          }
        ]
      }
    }
  }
}
