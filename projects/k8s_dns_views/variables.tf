variable "name" {
  description = "Name of the project"
  default     = "k8s-server-vm-clients"
}

variable "cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "owner" {
  default = "nwales"
}

variable "consul_license" {
  default = ""
}

variable "consul_binary" {
  default = "consul"
}