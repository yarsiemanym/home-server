resource "kubernetes_persistent_volume" "local" {
  metadata {
    name = "local"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "standard"

    capacity = {
      storage = "50Gi"
    }

    persistent_volume_source {
      local {
        path = "/data"
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "node.kubernetes.io/microk8s-controlplane"
            operator = "Exists"
          }
        }
      }
    }
  }
}
