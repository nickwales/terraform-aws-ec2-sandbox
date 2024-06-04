
resource "aws_s3_bucket" "consul-backup-bucket" {
  bucket = "${var.name}-consul-backup"

  tags = {
    Name = "${var.name}-consul-backup"
  }   
}