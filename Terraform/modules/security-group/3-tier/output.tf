output "alb_sg" {
  value       = aws_security_group.alb_sg
  description = "ALB security groups"
}

output "jumbox_sg" {
  value       = aws_security_group.jumpbox_sg
  description = "Jumbox security groups"
}

output "app_sg" {
  value       = aws_security_group.app_sg
  description = "Application security groups"
}

output "db_sg" {
  value       = aws_security_group.db_sg
  description = "DB security groups"
}
