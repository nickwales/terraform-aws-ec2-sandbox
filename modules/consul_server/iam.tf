resource "aws_iam_instance_profile" "consul_server" {
  name_prefix = "${var.name}-${var.datacenter}"
  role        = aws_iam_role.consul_server.name
}

resource "aws_iam_role" "consul_server" {
  name_prefix = "${var.name}-${var.datacenter}"
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "consul_server" {
  name_prefix = "${var.name}-${var.datacenter}"

  role = aws_iam_role.consul_server.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
              "ec2:DescribeInstances",
              "ec2:DescribeTags",
              "autoscaling:DescribeAutoScalingGroups",
          ]
          Effect = "Allow"
          Resource = "*"
        },
      ]
  })
}

resource "aws_iam_role_policy" "consul_server_backup" {
  name_prefix = "${var.name}-${var.datacenter}-s3-backup"

  role = aws_iam_role.consul_server.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:AbortMultipartUpload",
              "s3:ListBucket",
              "s3:DeleteObject",
              "s3:GetObjectVersion",
              "s3:ListMultipartUploadParts"
          ],
          "Resource": [
              "${aws_s3_bucket.consul-backup-bucket.arn}/*",
              "${aws_s3_bucket.consul-backup-bucket.arn}"
          ]
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "read-only-attach" {
  role       = aws_iam_role.consul_server.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  role       = aws_iam_role.consul_server.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}