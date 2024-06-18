locals {
  prefix = "${var.project_name}_${var.project_env}"
}

# Create application load balancer
resource "aws_lb" "alb" {
  name = replace("${local.prefix}-alb", "_", "-")

  internal           = false
  load_balancer_type = "application"

  security_groups = var.security_groups

  subnets = var.subnets

  tags = merge({
    Name = "${local.prefix}_alb"
  }, var.tags)
}

# Create target group
resource "aws_lb_target_group" "app_tg" {
  name     = replace("${local.prefix}-app-tg", "_", "-")
  port     = tonumber(var.app_port)
  protocol = "HTTP"
  vpc_id   = var.vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    unhealthy_threshold = 2
    timeout             = 5

    matcher  = 200
    path     = var.app_health_path
    port     = tonumber(var.app_port)
    protocol = "HTTP"
  }
  tags = merge({
    Name = "${var.project_name}_app_tg"
  }, var.tags)
}

# create a listener on app_port
resource "aws_lb_listener" "app_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = tonumber(var.app_port)
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = merge({
    Name = "${local.prefix}_app_lsn"
  }, var.tags)
}
