resource "aws_instance" "dc1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets[0]

  associate_public_ip_address = true
  
  vpc_security_group_ids = [aws_security_group.sandbox_server.id]
  iam_instance_profile   = aws_iam_instance_profile.doormat_profile.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
    ttl         = 72
    hc-internet-facing = "true"
    Name      = "nwales-sandbox-${var.dc1_name}"
    Owner     = "nwales"
    Purpose   = "Sandbox Testing"
    se_region = "AMER"
  }

  user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    dc            = var.dc1_name, 
    remote_dc     = var.dc2_name,
    consul_token  = var.consul_token,
    envoy_version = var.envoy_version
  } )
}

resource "aws_instance" "dc2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets[1]
  
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.sandbox_server.id]
  iam_instance_profile   = aws_iam_instance_profile.doormat_profile.name

  tags = {
    Terraform   = "true"
    Environment = "dev"
    ttl         = 72
    hc-internet-facing = "true"
    Name        = "nwales-sandbox-${var.dc2_name}"
    Owner       = "nwales"
    Purpose     = "Sandbox Testing"
    se_region   = "AMER"
  }

  user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    dc            = var.dc2_name, 
    remote_dc     = var.dc1_name,
    consul_token  = var.consul_token, 
    envoy_version = var.envoy_version  
  } )
}

