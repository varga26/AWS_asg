resource "aws_instance" "bastion" {
  ami                         = "ami-0886a1a9991170db6"
  instance_type               = "t3.micro"
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

