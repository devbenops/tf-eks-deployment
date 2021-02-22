variable "env" {
  default = "dev"
  type    = string
}

variable "aws_region" {
  default = "eu-central-1"
  type    = string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type    = string
}

variable "cluster_name" {
  default = "dev-cluster"
}

variable "zones" {
  type = list
  default = ["eu-central-1a","eu-central-1b","eu-central-1c", "eu-central-1c"]
}

variable "pub_cidr_blocks" {
  type = list
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.4.0/24","10.0.6.0/24"]
}