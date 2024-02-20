terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    helm ={
      source = "hashicorp/helm"
      version = "2.12.1"

    }
  }
}

provider "kubectl" {
  config_context_cluster = "kind-kind"
  config_path = "~/.kube/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_context_cluster = "kind-kind"
    config_path = "~/.kube/kubeconfig"
  }
}