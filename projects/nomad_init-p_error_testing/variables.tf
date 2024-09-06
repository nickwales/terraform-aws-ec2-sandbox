variable "name" {
  default = "nomad-error-testing"
}

variable "region" {
  default = "us-east-1"
}

variable "public_subnets" {
  default = ["10.0.1.0/24"]
}

variable "private_subnets" {
  default = ["10.0.101.0/24"]
}

variable "nomad_version" {
  default = "1.7.6"
}