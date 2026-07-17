resource "aws_iam_role" "grafana_agent_role" {
  name = "grafana-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.grafana_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_readonly_policy" {
  role       = aws_iam_role.grafana_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_instance_profile" "grafana_agent_profile" {
  name = "grafana-agent-profile"
  role = aws_iam_role.grafana_agent_role.name
}
