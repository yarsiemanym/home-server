resource "kubernetes_namespace" "pihole" {
  metadata {
    name = "pihole"
  }
}

resource "kubernetes_daemonset" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    selector {
      match_labels = {
        app = "pihole"
      }
    }

    template {
      metadata {
        labels = {
          app = "pihole"
        }
      }

      spec {
        container {
          image = "pihole/pihole"
          name  = "pihole"

          port {
            name           = "dns-tcp"
            protocol       = "TCP"
            container_port = 53
          }

          port {
            name           = "dns-udp"
            protocol       = "UDP"
            container_port = 53
          }

          port {
            name           = "dhcp"
            protocol       = "UDP"
            container_port = 67
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 80
          }

          env {
            name  = "TZ"
            value = "America/New York"
          }

          env {
            name  = "WEBPASSWORD"
            value = var.pihole_password
          }

          /* volume_mount {
            name = "lists"
            mount_path = "/etc/pihole/custom.lists"
            subpath = "custom.list"
          } */

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
          }
        }

        /* volume {
          name = "lists"
          config_map {
             name = kubernetes_config_map.custom_list.metadata.0.name
          }
        } */
      }
    }
  }
}

/* resource "kubernetes_config_map" "custom_list" {
  metadata {
    name      = "custom-list"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  data = {
    "custom.list" = <<-EOF
    
    EOF
  }
} */

resource "kubernetes_service" "pihole_dns" {
  metadata {
    name      = "pihole-dns"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    selector = {
      app = "pihole"
    }

    type = "LoadBalancer"
    load_balancer_ip = var.pihole_loadbalancer_ip

    port {
      name        = "dns-tcp"
      protocol    = "TCP"
      port        = 53
      target_port = 53
    }

    port {
      name        = "dns-udp"
      protocol    = "UDP"
      port        = 53
      target_port = 53
    }
  }
}

resource "kubernetes_service" "pihole_http" {
  metadata {
    name      = "pihole-http"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    selector = {
      app = "pihole"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.pihole_http.metadata.0.name
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
