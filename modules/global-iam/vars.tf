variable "aws_iam_role_eks_cluster" {
  description = "IAM role created for eks cluster"
  type        = string
}

variable "iam_role_worker_nodes" {
  description = "IAM role created for eks worker nodes"
  type        = string
}
