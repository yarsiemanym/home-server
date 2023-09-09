resource "kubernetes_secret" "aws" {
  metadata {
    name      = "aws"
    namespace = "kube-system"
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed" = "true"
      "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces": "cert-manager"
      "reflector.v1.k8s.emberstack.com/reflection-auto-enabled" = "true"
      "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces": "cert-manager"
    }
  }

  data = {
    region            = var.aws_region
    access_key_id     = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key
  }
}
