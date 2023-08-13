resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "observability"
  }

  spec {
    rule {
      host = "grafana.${var.local_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kube-prom-stack-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "observability"
  }

  spec {
    rule {
      host = "prometheus.${var.local_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-operated"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "pihole_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "pihole-exporter"
      namespace = "observability"
      labels = {
        release = "kube-prom-stack"
      }
    }

    spec = {
      namespaceSelector = {
        matchNames = [kubernetes_namespace.pihole.metadata.0.name]
      }

      selector = {
        matchLabels = {
          app = "pihole"
        }
      }

      endpoints = [
        {
          path     = "/metrics"
          port     = "http"
          interval = "60s"
        }
      ]
    }
  }
}
