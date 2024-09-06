module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


module "iam" {
  source = "../../modules/iam"

  name = var.name
}

resource "aws_instance" "dc1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  #iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
  iam_instance_profile = module.iam.aws_iam_instance_profile_name
  security_groups = [aws_security_group.sandbox_server.id]

  associate_public_ip_address = true

  key_name = "nwales-${var.region}"

  subnet_id = module.vpc.public_subnets[0]

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "${var.name}-server"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }
}

# resource "aws_instance" "dc1_client" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.small"
  
#   iam_instance_profile = module.iam.aws_iam_instance_profile_name
#   security_groups = [aws_security_group.sandbox_server.id]

#   associate_public_ip_address = true
#   key_name = "nwales-${var.region}"

#   subnet_id = module.vpc.public_subnets[0]

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

