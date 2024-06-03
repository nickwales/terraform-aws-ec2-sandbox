# Define the security group for the Windows server
resource "aws_security_group" "aws-windows-sg" {
  name        = "windows-sg"
  description = "Allow incoming connections"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    description = "Allow incoming DNS connections"
  }
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    description = "Allow incoming Consul gossip connections"
  }
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    description = "Allow incoming Consul HTTP connections"
  }
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
    description = "Allow incoming Consul DNS connections"
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "windows-sg"
  }
}
