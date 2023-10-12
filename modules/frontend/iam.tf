resource "aws_iam_instance_profile" "frontend" {
  name_prefix = "${var.name}-${var.datacenter}-frontend"
  role        = aws_iam_role.frontend.name
}

resource "aws_iam_role" "frontend" {
  name_prefix = "${var.name}-${var.datacenter}-frontend"
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

resource "aws_iam_role_policy" "frontend" {
    name_prefix = "${var.name}-${var.datacenter}-frontend"

    role = aws_iam_role.frontend.id
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
  role       = aws_iam_role.frontend.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  role       = aws_iam_role.frontend.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
