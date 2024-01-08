variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "name"
}

variable "node_group_name" {
  default = "node-group-one"
}

variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}