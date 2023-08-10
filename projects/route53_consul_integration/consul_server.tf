resource "aws_instance" "consul_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.consul_server.name
  vpc_security_group_ids = [aws_security_group.consul_server.id]
  subnet_id              = module.vpc.private_subnets[0]
  



  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "Consul Server"
    Purpose = "Integrating Consul with Route53"
    se_region = "AMER"
  }

  user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter = "dc1", 
    consul_token = var.consul_token
  } )
}