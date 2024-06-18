# Associate insance to target group
resource "aws_lb_target_group_attachment" "associate_app" {
  target_group_arn = var.aws_lb_target_group.arn
  target_id        = var.ec2_instance_id
  port             = tonumber(var.app_port)
}
