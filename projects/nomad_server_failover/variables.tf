variable "cluster_1_name" {
  default = "primary"
}

variable "cluster_2_name" {
  default = "secondary"
}

variable "region" {
  default = "us-east-1"
}

variable "cluster_1_public_subnets" {
  default = ["10.0.200.0/24"]
}

variable "cluster_1_private_subnets" {
  default = ["10.0.300.0/24"]
}

variable "cluster_2_public_subnets" {
  default = ["10.0.201.0/24"]
}

variable "cluster_2_private_subnets" {
  default = ["10.0.301.0/24"]
}