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
        matchNames = ["pihole"]
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