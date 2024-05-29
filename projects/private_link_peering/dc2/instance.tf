# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# resource "aws_security_group" "debug" {
#   name = "debug"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description      = "SSH Access"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "TCP"
#     cidr_blocks      = ["0.0.0.0/0"]    
#   }

#   ingress {
#     description      = "SSH Access"
#     from_port        = 4646
#     to_port          = 4646
#     protocol         = "TCP"
#     cidr_blocks      = ["0.0.0.0/0"]    

#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }


# module "iam" {
#   source = "../../../modules/iam"
#   name   = var.name
# }

# resource "aws_instance" "debug" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.small"
  
#   iam_instance_profile = module.iam.aws_iam_instance_profile_name
#   security_groups = [aws_security_group.debug.id]

#   associate_public_ip_address = false
#   key_name = "nwales-${var.region}"

#   subnet_id = module.vpc.private_subnets[0]

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#     ttl = 72
#     hc-internet-facing = "true"
#     Name = "${var.name}-client"
#     Owner = "nwales"
#     Purpose = "Sandbox Testing"
#     se_region = "AMER"
#   }
# }

# resource "aws_instance" "debug2" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.small"
  
#   iam_instance_profile = module.iam.aws_iam_instance_profile_name
#   security_groups = [aws_security_group.debug.id]

#   associate_public_ip_address = false
#   key_name = "nwales-${var.region}"

#   subnet_id = module.vpc.private_subnets[1]

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#     ttl = 72
#     hc-internet-facing = "true"
#     Name = "${var.name}-client2"
#     Owner = "nwales"
#     Purpose = "Sandbox Testing"
#     se_region = "AMER"
#   }
# }

