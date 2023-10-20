resource "aws_autoscaling_group" "nomad_client" {
  name                      = "nomad-client-${var.datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.nomad_client_count}"
  launch_template {
    id = aws_launch_template.nomad_client.id
  }
  target_group_arns         = var.target_groups
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "nomad-client-${var.datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "nomad_client" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_client.name
  }
  name = "nomad-client-${var.datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "nomad-client-${var.datacenter}",
      role = "nomad-client-${var.datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter            = var.datacenter, 
    nomad_version         = var.nomad_version,
    nomad_token           = var.nomad_token,
    nomad_encryption_key  = var.nomad_encryption_key,
    nomad_bootstrap_token = var.nomad_bootstrap_token,
    nomad_client_count    = var.nomad_client_count,
    nomad_key_file        = var.key_file,
    nomad_cert_file       = var.cert_file,
    nomad_binary          = var.nomad_binary, 
    nomad_ca_file         = var.ca_file,
    consul_ca_file        = var.consul_ca_file,
    consul_binary         = var.consul_binary,
    consul_version        = var.consul_version, 
    consul_ca_file        = var.consul_ca_file,
    consul_license        = var.consul_license,
    consul_token          = var.consul_token,
    consul_partition      = var.consul_partition,
    consul_agent_token    = var.consul_agent_token,
    consul_encryption_key = var.consul_encryption_key,
  }))
  vpc_security_group_ids = [aws_security_group.nomad_client.id]
}
