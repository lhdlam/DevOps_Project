locals {
  prefix = "${var.project_name}_${var.project_env}"
}

resource "aws_eip" "instance_eip" {
  domain   = "vpc"
  instance = var.ec2_instance.id

  tags = merge({
    Name = "${local.prefix}_jumpbox_eip"
  }, var.tags)
}
