variable "name" {
  default = "jumpbox"
}

variable "region" {
  default = "eu-west-2"
}

variable "public_subnets" {
  default = ["10.0.1.0/24"]
}

variable "private_subnets" {
  default = ["10.0.101.0/24"]
}