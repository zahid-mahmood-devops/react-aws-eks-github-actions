terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"  # Adjust version as necessary
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Assuming the Helm and Kubernetes providers are needed for the Prometheus module and potentially others

locals {
  eks_cluster_endpoint                 = module.eks_cluster.cluster_endpoint
  eks_cluster_certificate_authority_data = module.eks_cluster.cluster_certificate_authority_data
  # Token handling will require additional setup, discussed below
}
provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.eks_cluster_certificate_authority_data)
#  token                  = data.aws_eks_cluster_auth.cluster.token

#  load_config_file       = false
}
