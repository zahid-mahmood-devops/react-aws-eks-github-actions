output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.cap.name
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.cap.endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.cap.certificate_authority[0].data
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.cap.arn
}

