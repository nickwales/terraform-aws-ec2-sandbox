module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
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

resource "aws_instance" "nomad_server" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t3.small"
  
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

  user_data = base64encode(templatefile("${path.module}/templates/userdata_server.sh.tftpl", { 
      nomad_version   = var.nomad_version,
  }))
}


resource "aws_instance" "dc1_client_22" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t3.small"
  
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
    Name = "${var.name}-2204-client"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata_client.sh.tftpl", { 
      name          = var.name,
      nomad_version = var.nomad_version,      
  }))
}

resource "aws_instance" "dc1_client_20" {
  ami           = data.aws_ami.ubuntu_2004.id
  instance_type = "t3.small"
  
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
    Name = "${var.name}-2004-client"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata_client.sh.tftpl", { 
      name          = var.name,
      nomad_version = var.nomad_version,      
  }))
}

