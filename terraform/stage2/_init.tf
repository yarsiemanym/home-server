terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "microk8s"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "microk8s"
  }
}
