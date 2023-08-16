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
            value = var.pihole_timezone
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
            name       = "dnsmasq-data"
            mount_path = "/etc/dnsmasq.d"
          }

          volume_mount {
            name       = "pihole-data"
            mount_path = "/etc/pihole"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          startup_probe {
            http_get {
              path = "/admin"
              port = 80
            }
          }
        }

        container {
          image = "ekofr/pihole-exporter:v0.4.0"
          name  = "exporter"

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 9617
          }

          env {
            name  = "PIHOLE_HOSTNAME"
            value = "localhost"
          }

          env {
            name = "PIHOLE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.pihole_admin_password.metadata.0.name
                key  = "password"
              }
            }
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          startup_probe {
            http_get {
              path = "/metrics"
              port = 9617
            }
          }
        }

        init_container {
          image   = "busybox:1.36"
          name    = "init"
          command = ["/bin/sh"]
          args    = ["-c", "cp /tmp/dnsmasq/* /etc/dnsmasq.d/ && cp /tmp/pihole/* /etc/pihole/"]

          volume_mount {
            name       = "pihole-conf"
            mount_path = "/tmp/pihole"
          }

          volume_mount {
            name       = "dnsmasq-conf"
            mount_path = "/tmp/dnsmasq"
          }

          volume_mount {
            name       = "dnsmasq-data"
            mount_path = "/etc/dnsmasq.d"
          }

          volume_mount {
            name       = "pihole-data"
            mount_path = "/etc/pihole"
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "dnsmasq-data"
          persistent_volume_claim {
            claim_name = "dnsmasq-data"
          }
        }

        volume {
          name = "dnsmasq-conf"
          config_map {
            name = kubernetes_config_map.dnsmasq_conf.metadata.0.name
          }
        }

        volume {
          name = "pihole-data"
          persistent_volume_claim {
            claim_name = "pihole-data"
          }
        }

        volume {
          name = "pihole-conf"
          config_map {
            name = kubernetes_config_map.pihole_conf.metadata.0.name
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

resource "kubernetes_persistent_volume_claim" "dnsmasq_data" {
  metadata {
    name      = "dnsmasq-data"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Mi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pihole_data" {
  metadata {
    name      = "pihole-data"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

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
      ${join("\n", formatlist("%s pihole.${var.domain}", data.kubernetes_nodes.all_nodes.nodes.*.status.0.addresses.0.address))}
      ${join("\n", formatlist("%s grafana.${var.domain}", data.kubernetes_nodes.all_nodes.nodes.*.status.0.addresses.0.address))}
      ${join("\n", formatlist("%s prometheus.${var.domain}", data.kubernetes_nodes.all_nodes.nodes.*.status.0.addresses.0.address))}
      ${join("\n", formatlist("%s.${var.domain}", var.pihole_custom_dns_records))}
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
      DNSSEC=true
      REV_SERVER=false
      PIHOLE_DNS_1=${var.pihole_dns_1}
      PIHOLE_DNS_2=${var.pihole_dns_2}
      WEBUIBOXEDLAYOUT=traditional
      WEBTHEME=default-auto
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

resource "kubernetes_service" "pihole_exporter" {
  metadata {
    name      = "pihole-exporter"
    namespace = kubernetes_namespace.pihole.metadata.0.name
    labels = {
      app = "pihole"
    }
  }

  spec {
    selector = {
      app = "pihole"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9617
      target_port = 9617
    }
  }
}

resource "kubernetes_ingress_v1" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  spec {
    tls {
      hosts       = ["*.${var.domain}"]
      secret_name = kubernetes_manifest.wildcard_cert.manifest.metadata.name
    }
    rule {
      host = "pihole.${var.domain}"
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
