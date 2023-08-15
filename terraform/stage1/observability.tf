resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "observability"
  }

  spec {
    tls {
      hosts       = ["grafana.${var.domain}"]
      secret_name = kubernetes_manifest.grafana_cert.manifest.spec.secretName
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

resource "kubernetes_manifest" "grafana_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "grafana"
      namespace = "observability"
    }

    spec = {
      dnsNames    = ["grafana.${var.domain}"]
      duration    = "8760h0m0s" // 1 year
      renewBefore = "720h0m0s"  // 1 month
      secretName  = "grafana-cert"

      privateKey = {
        rotationPolicy = "Always"
      }

      issuerRef = {
        kind  = kubernetes_manifest.ca_issuer.manifest.kind
        name  = kubernetes_manifest.ca_issuer.manifest.metadata.name
        group = "cert-manager.io"
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
    tls {
      hosts       = ["prometheus.${var.domain}"]
      secret_name = kubernetes_manifest.prometheus_cert.manifest.spec.secretName
    }
    rule {
      host = "prometheus.${var.domain}"
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

resource "kubernetes_manifest" "prometheus_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "prometheus"
      namespace = "observability"
    }

    spec = {
      dnsNames    = ["prometheus.${var.domain}"]
      duration    = "8760h0m0s" // 1 year
      renewBefore = "720h0m0s"  // 1 month
      secretName  = "prometheus-cert"

      privateKey = {
        rotationPolicy = "Always"
      }

      issuerRef = {
        kind  = kubernetes_manifest.ca_issuer.manifest.kind
        name  = kubernetes_manifest.ca_issuer.manifest.metadata.name
        group = "cert-manager.io"
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
