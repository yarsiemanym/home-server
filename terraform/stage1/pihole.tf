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
            name  = "WEBPASSWORD"
            value = var.pihole_password
          }

          volume_mount {
            name       = "dnsmasq-conf"
            mount_path = "/etc/dnsmasq.d"
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

data "kubernetes_nodes" "all_nodes" {}

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
      server=208.67.222.222
      server=208.67.220.220
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

resource "kubernetes_config_map" "pihole_conf" {
  metadata {
    name      = "pihole-conf"
    namespace = kubernetes_namespace.pihole.metadata.0.name
  }

  data = {
    "custom.list" = <<-EOF
      ${join("\n", formatlist("%s pihole.${var.domain}", data.kubernetes_nodes.all_nodes.nodes.*.status.0.addresses.0.address))}
      ${join("\n", formatlist("%s.${var.domain}", var.additional_dns_records))}
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
      PIHOLE_DNS_1=208.67.222.222
      PIHOLE_DNS_2=208.67.220.220
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
