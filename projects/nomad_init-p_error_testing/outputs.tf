output "ip_address" {
  value = aws_instance.nomad_server.public_ip
}
