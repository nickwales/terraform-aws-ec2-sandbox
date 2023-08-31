resource "aws_instance" "consul_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  subnet_id              = module.vpc.private_subnets[0]  
  
  associate_public_ip_address = true

  tags = {
    Name = var.name
    Owner = var.owner
    Purpose = var.purpose
    se_region = var.region
    role = "consul-server"
  }

  user_data = templatefile("${path.module}/templates/consul_server.sh.tftpl", { 
    datacenter = "dc1", 
    consul_token = var.consul_token,
  } )
}

resource "aws_lb_target_group_attachment" "consul_server_ui" {
  target_group_arn = aws_lb_target_group.consul.arn
  target_id        = aws_instance.consul_server.id
  port             = 8500
}