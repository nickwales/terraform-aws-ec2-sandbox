resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile    = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-server-1"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "nomad-server"
  }

  user_data = templatefile("${path.module}/deploy/nomad_testing/templates/userdata_server.sh.tftpl", {})
}

resource "aws_instance" "client" {
  count = 2

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-client-${count.index}"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "nomad-client"
  }

  user_data = templatefile("${path.module}/deploy/nomad_testing/templates/userdata_client.sh.tftpl", { client_number = count.index, role = "app" })
}


resource "aws_instance" "proxy" {
  count = 1
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  
  iam_instance_profile = aws_iam_instance_profile.instance.name

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = "nomad-proxy-${count.index}"
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
    Role = "nomad-client"
  }

  user_data = templatefile("${path.module}/deploy/nomad_testing/templates/userdata_client.sh.tftpl", {client_number = count.index, role = "proxy"})
}
