output "vpc" {
  value       = aws_vpc.vpc
  description = "VPC info"
}

output "igw" {
  value       = aws_internet_gateway.igw
  description = "Public subnet az1"
}

output "public_rt" {
  value       = aws_route_table.public_rt
  description = "Public route"
}

output "private_route" {
  value       = aws_route_table.private_rt
  description = "Public route"
}

output "public_sn_az1" {
  value       = aws_subnet.public_sn_az1
  description = "Public subnet az1"
}

output "public_sn_az2" {
  value       = aws_subnet.public_sn_az2
  description = "Public subnet az2"
}

output "private_sn_az1" {
  value       = aws_subnet.private_sn_az1
  description = "Privatte subnet az1"
}

output "private_sn_az2" {
  value       = aws_subnet.private_sn_az2
  description = "Privatte subnet az2"
}

output "peer_route_table_id" {
  value       = aws_route_table.private_rt.id
  description = "Get route_table_id for peering"
}
