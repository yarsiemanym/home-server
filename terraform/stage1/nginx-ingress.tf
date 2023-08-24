data "kubernetes_nodes" "all_nodes" {}


resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = "ingress"
  create_namespace = true
  repository       = "oci://ghcr.io/nginxinc/charts"
  chart            = "nginx-ingress"

  values = [
    templatefile("./nginx-ingress.yaml", {
      EXTERNAL_IP = data.kubernetes_nodes.all_nodes.nodes.0.status.0.addresses.0.address
      }
  )]
}
