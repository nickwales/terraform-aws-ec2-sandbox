output "dc1_address" {
  value = "http://${aws_instance.dc1.public_ip}:8500"
}

output "dc2_address" {
  value = "http://${aws_instance.dc2.public_ip}:8500"
}