resource "helm_release" "reflector" {
  name             = "reflector"
  namespace        = "reflector"
  create_namespace = true
  repository       = "https://emberstack.github.io/helm-charts"
  chart            = "reflector"
}
