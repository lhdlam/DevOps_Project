output "alb" {
  value       = aws_lb.alb
  description = "Application loadbalancer"
}

output "app_target_group" {
  value       = aws_lb_target_group.app_tg
  description = "Application target group"
}

output "app_http_listener" {
  value       = aws_lb_listener.app_http_listener
  description = "Application http listener"
}
