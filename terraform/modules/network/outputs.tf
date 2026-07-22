output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_1_id" {
  description = "Public Subnet 1 (AZ1) ID"
  value       = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "Public Subnet 2 (AZ2) ID"
  value       = aws_subnet.public_subnet_2.id
}

output "private_subnet_1_az_id" {
  description = "Private Subnet 1 (Compute, AZ1) ID"
  value       = aws_subnet.private_subnet_1_AZ.id
}

output "private_subnet_2_az_id" {
  description = "Private Subnet 2 (Compute, AZ2) ID"
  value       = aws_subnet.private_subnet_2_AZ.id
}

output "private_subnet_1_rds_id" {
  description = "Private Subnet 1 (RDS, AZ1) ID"
  value       = aws_subnet.private_subnet_1_RDS.id
}

output "private_subnet_2_rds_id" {
  description = "Private Subnet 2 (RDS, AZ2) ID"
  value       = aws_subnet.private_subnet_2_RDS.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_1_id" {
  description = "NAT Gateway 1 (AZ1) ID"
  value       = aws_nat_gateway.nat_gw1.id
}

output "nat_gateway_2_id" {
  description = "NAT Gateway 2 (AZ2) ID"
  value       = aws_nat_gateway.nat_gw2.id
}

output "nat_gateway_1_public_ip" {
  description = "Public IP of NAT Gateway 1"
  value       = aws_eip.nat_eip1.public_ip
}

output "nat_gateway_2_public_ip" {
  description = "Public IP of NAT Gateway 2"
  value       = aws_eip.nat_eip2.public_ip
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_1_id" {
  description = "Private Route Table 1 (AZ1) ID"
  value       = aws_route_table.private_route_table1.id
}

output "private_route_table_2_id" {
  description = "Private Route Table 2 (AZ2) ID"
  value       = aws_route_table.private_route_table2.id
}

output "network_summary" {
  description = "Summary of network configuration"
  value = {
    vpc_cidr           = aws_vpc.vpc.cidr_block
    public_subnets     = [aws_subnet.public_subnet_1.cidr_block, aws_subnet.public_subnet_2.cidr_block]
    private_compute    = [aws_subnet.private_subnet_1_AZ.cidr_block, aws_subnet.private_subnet_2_AZ.cidr_block]
    private_database   = [aws_subnet.private_subnet_1_RDS.cidr_block, aws_subnet.private_subnet_2_RDS.cidr_block]
    nat_gateways       = 2
    availability_zones = [aws_subnet.public_subnet_1.availability_zone, aws_subnet.public_subnet_2.availability_zone]
  }
}
