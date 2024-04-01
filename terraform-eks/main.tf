# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets associated with the default VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
#cluster provision
#resource "aws_eks_cluster" "cap" {
#  name     = "EKS_cluster_CAP"
#  role_arn = aws_iam_role.cap.arn
#}
module "eks_cluster" {
  source = "./eks_module"

  cluster_name = "EKS_cluster_capautomation"
  subnet_ids   = data.aws_subnets.public.ids
#  subnet_ids      = ["subnet-xxxxxx", "subnet-yyyyyy"]
  desired_size    = 1
  max_size        = 2
  min_size        = 1
  instance_types  = ["t3.medium"]
}


