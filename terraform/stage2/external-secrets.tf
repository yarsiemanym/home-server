resource "kubernetes_manifest" "aws_secrets_manager" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-secrets-manager"
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.kubernetes_secret.aws.data.region
          auth = {
            secretRef = {
              accessKeyIDSecretRef = {
                name      = data.kubernetes_secret.aws.metadata.0.name
                namespace = "kube-system"
                key       = "access_key_id"
              }

              secretAccessKeySecretRef = {
                name      = data.kubernetes_secret.aws.metadata.0.name
                namespace = data.kubernetes_secret.aws.metadata.0.namespace
                key       = "secret_access_key"
              }
            }
          }
        }
      }
    }
  }
}
