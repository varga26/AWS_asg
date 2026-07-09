output "bastion_public_ip" {
  description = "The public IP of the Bastion Host for SSH access"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "The private IP of the Bastion Host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the Bastion Host"
  value       = aws_instance.bastion.id
}


output "bastion_ssh_command" {
  description = "SSH command to connect to Bastion"
  value       = "ssh -i /path/to/my-aws-key.pem ubuntu@${aws_instance.bastion.public_ip}"
}
