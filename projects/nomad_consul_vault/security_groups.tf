resource "aws_security_group" "lb" {
  name_prefix = "${var.name}-dc1"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 8500
    to_port          = 8500
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  ingress {
    description      = "HTTP"
    from_port        = 8500
    to_port          = 8500
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  } 

  ingress {
    description      = "HTTP"
    from_port        = 4646
    to_port          = 4646
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  } 

  ingress {
    description      = "HTTP"
    from_port        = 8200
    to_port          = 8200
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}