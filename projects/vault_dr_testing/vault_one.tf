resource "aws_instance" "vault_one" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.instance.name
  vpc_security_group_ids = [aws_security_group.vault_server.id]
  subnet_id              = module.vpc.private_subnets[0]  
  
  associate_public_ip_address = false

  tags = {
    Name = "vault-one"
    Owner = var.owner
    Purpose = var.purpose
    se_region = var.region
    role = "vault-server-one"
  }

  user_data = templatefile("${path.module}/templates/vault_server.sh.tftpl", { 
    datacenter = "dc1",
    consul_token = var.consul_token,
    cluster_role = "primary",
    vault_ent_license = var.vault_ent_license,
    role = "vault-server-one",
    region = var.region,    
  } )
}

resource "aws_lb_target_group_attachment" "vault_one" {
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.vault_one.id
  port             = 8200
}


## Instance 2
resource "aws_instance" "vault_one_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.instance.name
  vpc_security_group_ids = [aws_security_group.vault_server.id]
  subnet_id              = module.vpc.private_subnets[0]  
  
  associate_public_ip_address = false

  tags = {
    Name = "vault-one"
    Owner = var.owner
    Purpose = var.purpose
    se_region = var.region
    role = "vault-server-one"
  }

  user_data = templatefile("${path.module}/templates/vault_server.sh.tftpl", { 
    datacenter = "dc1",
    consul_token = var.consul_token,
    cluster_role = "primary",
    vault_ent_license = var.vault_ent_license,
    role = "vault-server-one",
    region = var.region,    
  } )
}

resource "aws_lb_target_group_attachment" "vault_one_2" {
  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = aws_instance.vault_one.id
  port             = 8200
}