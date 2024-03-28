# Assume Role Policy Document for EKS Cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cap" {
  name               = "eks-cluster-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# IAM Role Policy Attachments for EKS Cluster
resource "aws_iam_role_policy_attachment" "cap-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cap.name
}

# EKS Cluster
resource "aws_eks_cluster" "cap" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cap.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cap-AmazonEKSClusterPolicy,
  ]
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "cap1" {
  name = "eks-node-group-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Node Group IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "cap-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cap1.name
}

resource "aws_iam_role_policy_attachment" "cap-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cap1.name
}

resource "aws_iam_role_policy_attachment" "cap-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cap1.name
}

# EKS Node Group EC2 Policy (that was missing in the previous response)
resource "aws_iam_policy" "eks_node_group_ec2_policy" {
  name        = "eks-node-group-ec2-policy-${var.cluster_name}"
  description = "EKS Node Group policy for EC2 actions required by EBS CSI Driver"
  policy      = var.eks_node_group_ec2_policy
}

resource "aws_iam_role_policy_attachment" "eks_node_group_ec2_policy_attachment" {
  policy_arn = aws_iam_policy.eks_node_group_ec2_policy.arn
  role       = aws_iam_role.cap1.name
}

# EKS Node Group
resource "aws_eks_node_group" "cap" {
  cluster_name    = aws_eks_cluster.cap.name
  node_group_name = "Node-cloud-${var.cluster_name}"
  node_role_arn   = aws_iam_role.cap1.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  depends_on = [
    aws_iam_role_policy_attachment.cap-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cap-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cap-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_group_ec2_policy_attachment,
  ]
}

# Update kubeconfig
resource "null_resource" "update_kubeconfig" {
  depends_on = [aws_eks_cluster.cap]

  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.cap.name}"
  }
}

# Install EBS CSI Driver
resource "null_resource" "install_ebs_csi_driver" {
  depends_on = [null_resource.update_kubeconfig]

  provisioner "local-exec" {
    command = "kubectl apply -k \"github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable?ref=master\""
  }
}

