resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws"
    namespace = "kube-system"
  }

  data = {
    region            = var.aws_region
    access_key_id     = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key
  }
}
