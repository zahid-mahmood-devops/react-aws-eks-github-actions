variable "aws_region" {
  description = "AWS region where the EKS cluster is located"
  type        = string
  default     = "us-west-2"
}

variable "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  type        = string
}

variable "cluster_ca_data" {
  description = "EKS Cluster CA Certificate Data"
  type        = string
}

variable "cluster_token" {
  description = "EKS Cluster Auth Token"
  type        = string
}

