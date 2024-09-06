resource "aws_security_group" "sandbox_server" {
  name = "sandbox_server"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]    
    // cidr_blocks      = [aws_vpc.main.cidr_block]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "SSH Access"
    from_port        = 4646
    to_port          = 4646
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]    
    // cidr_blocks      = [aws_vpc.main.cidr_block]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "http Access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]    
    // cidr_blocks      = [aws_vpc.main.cidr_block]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}