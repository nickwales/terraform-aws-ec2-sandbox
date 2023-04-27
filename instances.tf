resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
  //vpc_security_group_ids = [aws_security_group.sandbox_server.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nwales-sandbox-web"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }
}

resource "aws_instance" "backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile    = aws_iam_instance_profile.doormat_profile.name
  //vpc_security_group_ids = [aws_security_group.sandbox_server.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nwales-sandbox-backend"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }
}


// resource "aws_network_interface" "web" {
//   subnet_id   = aws_subnet.my_subnet.id
//   private_ips = ["172.16.10.100"]

//   tags = {
//     Name = "primary_network_interface"
//   }
// } 
