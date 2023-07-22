resource "kubernetes_manifest" "ip_address_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"

    metadata = {
      name      = "metallb"
      namespace = "metallb-system"
    }

    spec = {
      addresses = var.metallb_ip_address_pool
    }
  }
}