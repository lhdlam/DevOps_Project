output "public_sg" {
  value       = aws_security_group.public_sg
  description = "Public security groups"
}

output "private_sg" {
  value       = aws_security_group.private_sg
  description = "Private security groups"
}
