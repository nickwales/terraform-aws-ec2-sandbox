resource "aws_instance" "dnsperf" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]
  subnet_id              = module.vpc.private_subnets[0]  
  
  associate_public_ip_address = true

  tags = {
    Name = "dnsperf"
    role = "dnsperf"
  }

  user_data = templatefile("${path.module}/templates/dnsperf.sh.tftpl", {} )
}
