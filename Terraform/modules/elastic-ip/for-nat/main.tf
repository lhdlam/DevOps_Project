locals {
  prefix = "${var.project_name}_${var.project_env}"
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge({
    Name = "${local.prefix}_nat_eip"
  }, var.tags)
}
