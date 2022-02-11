terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.11.3"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.4.1"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.3.0"
    }

    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "3.1.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }

    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.6.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "../kubeconfig.yaml"
  config_context = var.kubecontext
}

provider "kubectl" {
  config_path    = "../kubeconfig.yaml"
  config_context = var.kubecontext
}

provider "helm" {
  kubernetes {
    config_path = "../kubeconfig.yaml"
  }
}

provider "keycloak" {
    client_id     = "admin-cli"
    username      = "admin"
    password      = random_string.keycloak_admin_password.result
    url           = "http://localhost:8080"
    tls_insecure_skip_verify = true
}