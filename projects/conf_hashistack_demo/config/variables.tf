#variable "consul_management_token" {}

# variable "hostname" {
#   description = "Hostname to pass to API Gateway"
# }

variable "job_region" {
  description = "The region the job will display"
}

variable "datacenter" {
  description = "The Datacenter to use"
  default     = "dc1"
}

variable "peer" {
  description = "The peer for a sameness group"
  default     = "dc2"
}