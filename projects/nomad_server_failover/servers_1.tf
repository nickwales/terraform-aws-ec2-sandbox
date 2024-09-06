module "iam" {
  source = "../../modules/iam"

  name = var.cluster_1
}

resource "aws_instance" "dc1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  #iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
  iam_instance_profile = module.iam.aws_iam_instance_profile_name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = var.name
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }
}

