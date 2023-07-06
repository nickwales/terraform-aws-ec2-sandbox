resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_subnets[0]
  
  count = var.server_count

  vpc_security_group_ids = [aws_security_group.sandbox_server.id]
  iam_instance_profile    = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-server-1"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "hashistack-server"
  }

  user_data = templatefile("${path.module}/templates/userdata_server.sh.tftpl", { 
    count             = var.server_count,
    consul_token      = var.consul_token,
    consul_datacenter = var.consul_datacenter
  })
}

resource "aws_instance" "client" {
  count = var.client_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_subnets[0]
  
  vpc_security_group_ids = [aws_security_group.sandbox_server.id]
  iam_instance_profile = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-client-${count.index}"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "hashistack-client"
  }

  user_data = templatefile("${path.module}/templates/userdata_client.sh.tftpl", { 
    client_number     = count.index,
    role              = "app",
    consul_token      = var.consul_token,
    consul_datacenter = var.consul_datacenter
  })
}


resource "aws_instance" "proxy" {
  count = 0
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_subnets[0]
  
  vpc_security_group_ids = [aws_security_group.sandbox_server.id]
  iam_instance_profile = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-proxy-${count.index}"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "hashistack-client"
  }

  user_data = templatefile("${path.module}/templates/userdata_client.sh.tftpl", {
    client_number     = count.index,
    role              = "proxy",
    consul_token      = var.consul_token,
    consul_datacenter = var.consul_datacenter
  })
}
