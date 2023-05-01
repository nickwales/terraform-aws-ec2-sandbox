resource "aws_instance" "dc1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nwales-sandbox-dc1"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }

  user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter = "dc1", 
    consul_token = var.consul_token,
    envoy_version = var.envoy_version
  } )
}

resource "aws_instance" "dc2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nwales-sandbox-dc2"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }

  user_data = templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter = "dc2", 
    consul_token = var.consul_token, 
    envoy_version = var.envoy_version  
  } )
}


// resource "aws_network_interface" "web" {
//   subnet_id   = aws_subnet.my_subnet.id
//   private_ips = ["172.16.10.100"]

//   tags = {
//     Name = "primary_network_interface"
//   }
// } 
