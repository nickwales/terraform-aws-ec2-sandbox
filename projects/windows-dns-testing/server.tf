resource "aws_instance" "windows-server" {
  ami           = data.aws_ami.windows-2019.id
  instance_type = var.windows_instance_type


  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  subnet_id              = module.vpc.public_subnets[0]  
  
  associate_public_ip_address = true
  
  source_dest_check = false
  key_name = var.keyname
  user_data = templatefile("${path.module}/templates/acrylic-dns.ps1.tftpl", {
    windows_instance_name = "windows_consul_server",
    envoy_folder         = "envoy",
    consul_folder        = "consul",
    consul_config_folder = "config",
    consul_certs_folder  = "config",
    hashicups_folder     = "hashicups",
    consul_url           = var.consul_url,
    consul_version       = var.consul_version,
    envoy_url            = var.envoy_url,
    consul_token         = var.consul_token,
  })
  
  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.windows_data_volume_size
    volume_type           = var.windows_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "windows-consul-server",
    Role = "consul-server",
  }
}

# resource "aws_instance" "windows-server-client" {
#   ami = data.aws_ami.windows-2019.id
#   instance_type = var.windows_instance_type
#   subnet_id = var.subnet
#   vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]
#   source_dest_check = false
#   key_name = "nick"
#   user_data = templatefile("${path.module}/templates/user-data.tftpl", {
#     windows_instance_name = "windows_consul_client",
#     envoy_folder    = "envoy",
#     consul_folder   = "consul",
#     consul_config_folder = "config",
#     consul_certs_folder = "config",
#     hashicups_folder    = "hashicups",
#     consul_url = var.consul_url,
#     envoy_url = var.envoy_url  
#   })
#   associate_public_ip_address = var.windows_associate_public_ip_address
  
#   # root disk
#   root_block_device {
#     volume_size           = var.windows_root_volume_size
#     volume_type           = var.windows_root_volume_type
#     delete_on_termination = true
#     encrypted             = true
#   }
#   # extra disk
#   ebs_block_device {
#     device_name           = "/dev/xvda"
#     volume_size           = var.windows_data_volume_size
#     volume_type           = var.windows_data_volume_type
#     encrypted             = true
#     delete_on_termination = true
#   }
  
#   tags = {
#     Name        = "windows-server-vm-client"
#   }
# }
