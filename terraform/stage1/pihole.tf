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
          image = "pihole/pihole:2023.05.2"
          name  = "pihole"

          port {
            name           = "dns-tcp"
            protocol       = "TCP"
            container_port = 53
            host_port      = 53
          }

          port {
            name           = "dns-udp"
            protocol       = "UDP"
            container_port = 53
            host_port      = 53
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
            name = "WEBPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.pihole_admin_password.metadata.0.name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "dnsmasq-conf"
            mount_path = "/etc/dnsmasq.d"
          }

          volume_mount {
            name       = "pihole-data"
            mount_path = "/etc/pihole"
          }

          volume_mount {
            name       = "pihole-conf"
            mount_path = "/etc/pihole/custom.list"
            sub_path   = "custom.list"
          }

          volume_mount {
            name       = "pihole-conf"
            mount_path = "/etc/pihole/setupVars.conf"
            sub_path   = "setupVars.conf"
          }

          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/admin"
              port = 80
            }
          }
        }

        volume {
          name = "pihole-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pihole_data.metadata.0.name
          }
        }

        volume {
          name = "pihole-conf"
          config_map {
            name = kubernetes_config_map.pihole_conf.metadata.0.name
          }
        }

        volume {
          name = "dnsmasq-conf"
          config_map {
            name = kubernetes_config_map.dnsmasq_conf.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "pihole_admin_password" {
  metadata {
    name      = "pihole-admin-password"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  data = {
    password = var.pihole_admin_password
  }
}

resource "kubernetes_persistent_volume_claim" "pihole_data" {
  metadata {
    name      = "pihole-data"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "standard"

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "dnsmasq_conf" {
  metadata {
    name      = "dnsmasq-conf"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  data = {
    "01-pihole.conf" = <<-EOF
      addn-hosts=/etc/pihole/local.list
      addn-hosts=/etc/pihole/custom.list


      localise-queries


      no-resolv

      log-queries
      log-facility=/var/log/pihole/pihole.log

      log-async
      cache-size=10000
      server=${var.pihole_dns_1}
      server=${var.pihole_dns_2}
      domain-needed
      expand-hosts
      bogus-priv
      except-interface=nonexisting
    EOF

    "06-rfc6761.conf" = <<-EOF
      server=/test/
      server=/localhost/
      server=/invalid/
      server=/bind/
      server=/onion/
    EOF
  }
}

data "kubernetes_nodes" "all_nodes" {}

resource "kubernetes_config_map" "pihole_conf" {
  metadata {
    name      = "pihole-conf"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  data = {
    "custom.list" = <<-EOF
      ${join("\n", formatlist("%s pihole.${var.local_domain}", data.kubernetes_nodes.all_nodes.nodes.*.status.0.addresses.0.address))}
      ${join("\n", formatlist("%s.${var.local_domain}", var.custom_dns_records))}
    EOF

    "setupVars.conf" = <<-EOF
      PIHOLE_INTERFACE=eth0
      IPV4_ADDRESS=0.0.0.0
      IPV6_ADDRESS=0:0:0:0:0:0
      QUERY_LOGGING=true
      INSTALL_WEB_SERVER=true
      INSTALL_WEB_INTERFACE=true
      LIGHTTPD_ENABLED=true
      CACHE_SIZE=10000
      DNS_FQDN_REQUIRED=true
      DNS_BOGUS_PRIV=true
      DNSMASQ_LISTENING=all
      BLOCKING_ENABLED=true
      TEMPERATUREUNIT=F
      DNSSEC=false
      REV_SERVER=false
      PIHOLE_DNS_1=${var.pihole_dns_1}
      PIHOLE_DNS_2=${var.pihole_dns_2}
    EOF
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
      host = "pihole.${var.local_domain}"
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
