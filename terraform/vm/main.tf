resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_1_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_pair_name
  root_block_device {
    volume_size = 8
  }
  tags = {
    Name = "bastion"
  }
}

data "aws_ami" "grafana" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["grafana-alloy-*"]
  }
}
resource "aws_instance" "grafana" {
  ami                         = data.aws_ami.grafana.id
  instance_type               = var.grafana_instance_type
  subnet_id                   = var.private_subnet_1_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.grafana_sg_id]
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.grafana_agent_profile.name
  root_block_device {
    volume_size = 15
  }
  tags = {
    Name = "grafana"
  }
}



