resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "observability"
  }

  spec {
    tls {
      hosts       = ["*.${var.domain}"]
      secret_name = kubernetes_manifest.wildcard_cert.manifest.metadata.name
    }
    rule {
      host = "grafana.${var.domain}"
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
