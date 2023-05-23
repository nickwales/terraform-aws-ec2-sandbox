resource "aws_iam_instance_profile" "doormat_profile" {
  name_prefix = "consul_server"
  role        = aws_iam_role.doormat_role.name
}

resource "aws_iam_role" "doormat_role" {
  name_prefix = "doormat_role"
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

resource "aws_iam_role_policy" "doormat_policy" {
    name_prefix = "doormat_policy"

    role = aws_iam_role.doormat_role.id
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
  role       = aws_iam_role.doormat_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  role       = aws_iam_role.doormat_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}