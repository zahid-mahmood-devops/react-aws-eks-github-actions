terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    kubernetes = {
        version = ">= 2.0.0"
        source = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}


data "aws_eks_cluster" "EKS_cluster_capautomation" {
  name = "EKS_cluster_capautomation"
}
data "aws_eks_cluster_auth" "EKS_cluster_capautomation_auth" {
  name = "EKS_cluster_capautomation_auth"
}


provider "aws" {
  region     = "us-west-2"
}

provider "helm" {
    kubernetes {
      config_path = "~/.kube/config"
    }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
   load_config_file = false
   host                   = data.aws_eks_cluster.EKS_cluster_capautomation.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.EKS_cluster_capautomation.certificate_authority[0].data)
   token                  = data.aws_eks_cluster_auth.EKS_cluster_capautomation_auth.token
    config_path = "~/.kube/config"
    }
