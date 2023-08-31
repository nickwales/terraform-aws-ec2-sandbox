resource "aws_instance" "consul_client_two" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  subnet_id              = module.vpc.private_subnets[0]  
  
  associate_public_ip_address = true

  tags = {
    Name = "${var.name}-client-two"
    Owner = var.owner
    Purpose = var.purpose
    se_region = var.region
  }

  user_data = templatefile("${path.module}/templates/consul_client.sh.tftpl", { 
    datacenter   = "dc1", 
    consul_token = var.consul_token,
    db_type      = "read-only",
  } )
}


resource "aws_lb_target_group_attachment" "consul_client_two_frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.consul_client_two.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "consul_client_two_stats" {
  target_group_arn = aws_lb_target_group.stats.arn
  target_id        = aws_instance.consul_client_two.id
  port             = 9000
}