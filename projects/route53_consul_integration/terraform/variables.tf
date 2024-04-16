variable "name" {
  default = "consul_route53_integration"
}

variable "consul_token" {
  default = "root"
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "account_one_id" {}