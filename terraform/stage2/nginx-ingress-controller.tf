resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = "nginx-ingress"
  create_namespace = true
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "nginx-ingress-controller"

  values = [templatefile("./nginx-ingress-controller.yaml", {
    LOADBALANCER_IP = var.ingress_loadbalancer_ip
  })]

  depends_on = [kubernetes_manifest.ip_address_pool]
}
