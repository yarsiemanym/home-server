resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_viewer" {
  metadata {
    name = "external-dns-viewer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns.metadata.0.name
    namespace = kubernetes_namespace.external_dns.metadata.0.name
  }
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata.0.name
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          app = "external-dns"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.external_dns.metadata.0.name

        container {
          name  = "external-dns"
          image = "registry.k8s.io/external-dns/external-dns:v0.13.5"

          args = [
            "--source=service",
            "--source=ingress",
            "--registry=noop",
            "--policy=upsert-only",
            "--provider=pihole",
            "--pihole-server=http://${kubernetes_service.pihole.metadata.0.name}.${kubernetes_service.pihole.metadata.0.namespace}.svc.cluster.local"
          ]

          env {
            name = "EXTERNAL_DNS_PIHOLE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.pihole_admin_password.metadata.0.name
                key  = "password"
              }
            }
          }
        }

        security_context {
          fs_group = 65534
        }
      }
    }
  }
}
