# Assuming your kubeconfig is correctly set up, you might not need to explicitly depend on the EKS node group.
# However, if you want to ensure that the Kubernetes and Helm providers only run after the EKS cluster is fully ready,
# consider using a data source to fetch the cluster details and establish an implicit dependency.

data "aws_eks_cluster" "eks_cluster" {
  name = "EKS_cluster_capautomation"  # Ensure this matches your EKS cluster name
}

# A brief pause to ensure the cluster is fully ready before attempting to interact with it.
# Adjust the duration as per your cluster's typical readiness time.
resource "time_sleep" "wait_for_kubernetes" {
  create_duration = "20s"
}

# Create the namespace for Prometheus. The dependency on the time_sleep resource helps ensure the cluster is ready.
resource "kubernetes_namespace" "kube_namespace" {
  depends_on = [time_sleep.wait_for_kubernetes]
  metadata {
    name = "prometheus"
  }
}

# Deploy Prometheus using the Helm chart.
# This setup assumes you have a 'values.yaml' file in the same directory with your desired configurations.
resource "helm_release" "prometheus" {
  depends_on        = [kubernetes_namespace.kube_namespace]
  name              = "prometheus"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  namespace         = kubernetes_namespace.kube_namespace.metadata[0].name
  create_namespace  = true  # This is redundant since you're already creating the namespace above.
  version           = "45.7.1"
  values            = [file("${path.module}/values.yaml")]

  set {
    name  = "podSecurityPolicy.enabled"
    value = "true"
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }

  set {
    name  = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      },
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

