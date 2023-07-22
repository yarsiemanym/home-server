resource "helm_release" "metallb" {
  name             = "metallb"
  namespace        = "metallb-system"
  create_namespace = true
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "metallb"

  values = [templatefile("./metallb.yaml", {})]
}
