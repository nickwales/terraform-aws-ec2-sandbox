variable "name" {
  default = "windows-consul"
}

variable "keyname" {}

variable "consul_token" {
  default = "root"
}

variable "consul_version" {
  default = "1.16.2"
}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "m5.large"
}
variable "windows_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}
variable "windows_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "30"
}
variable "windows_data_volume_size" {
  type        = number
  description = "Volumen size of data volumen of Windows Server"
  default     = "10"
}
variable "windows_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}
variable "windows_data_volume_type" {
  type        = string
  description = "Volumen type of data volumen of Windows Server."
  default     = "gp2"
}
variable "windows_instance_name" {
  type        = string
  description = "EC2 instance name for Windows Server"
  default     = "tfwinsrv01"
}

# variable "subnet" {
#   description = "Subnet"
# }

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

# variable "vpc" {
#   description = "VPC"
# }

variable "consul_url" {
  type        = string
  description = "Consul URL"
  default     = "https://consul-windows-preview.s3.us-west-2.amazonaws.com/consul/consul_1.15.0_windows_amd64.zip"
}

variable "consul_base_folders" {
  type        = map(string)
  description = "Consul folders structure"
  default = {
    consul_folder        = "consul"
    consul_config_folder = "config"
    consul_certs_folder  = "certs"
  }
}

variable "envoy_url" {
  default = "https://consul-windows-preview.s3.us-west-2.amazonaws.com/envoy/v1.23/envoy.exe"
}

variable "fakeservice_url" {
  default = "https://github.com/nicholasjackson/fake-service/releases/download/v0.24.2/fake_service_windows_amd64.zip"
}
