resource "kubernetes_manifest" "pihole_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "pihole-exporter"
      namespace = "observability"
      labels = {
        release = "observability"
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
          port     = "metrics"
          scheme   = "http"
          interval = "60s"
        }
      ]
    }
  }
}
