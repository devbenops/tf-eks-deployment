variable "aws_iam_role_eks_cluster" {
  default = "eks-demo-cluster-role"
  type    = string
}

variable "iam_role_worker_nodes" {
  default = "EKS-worker-node-role"
  type = string
}

variable "aws_region" {
  default = "eu-central-1"
}