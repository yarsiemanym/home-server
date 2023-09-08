data "kubernetes_secret" "aws" {
  metadata {
    name      = "aws"
    namespace = "kube-system"
  }
}
