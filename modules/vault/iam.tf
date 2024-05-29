resource "aws_iam_instance_profile" "profile" {
  name_prefix = "${var.name}-${var.consul_datacenter}"
  role        = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name_prefix = "${var.name}-${var.consul_datacenter}"
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

resource "aws_iam_role_policy" "policy" {
    name_prefix = "${var.name}-${var.consul_datacenter}"

    role = aws_iam_role.role.id
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

resource "aws_iam_role_policy_attachment" "read-only-attach" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  role       = aws_iam_role.role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
