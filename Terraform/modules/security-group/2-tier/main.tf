locals {
  prefix = "${var.project_name}_${var.project_env}"

  private_ingress_rules = concat(
    [{
      description      = "Accept ssh from Public"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [aws_security_group.public_sg.id]
    }],
    var.private_ingress_rules
  )
}

resource "aws_security_group" "public_sg" {
  vpc_id = var.vpc.id

  name        = "${local.prefix}_public_sg"
  description = "Public security group"

  dynamic "ingress" {
    for_each = var.public_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.from_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = ingress.value.security_groups
      self             = false
    }
  }

  dynamic "egress" {
    for_each = var.public_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.from_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = egress.value.security_groups
      self             = false
    }
  }

  tags = merge({
    Name = "${local.prefix}_private_sg"
  }, var.tags)
}

resource "aws_security_group" "private_sg" {
  vpc_id      = var.vpc.id
  name        = "${local.prefix}_private_sg"
  description = "Private security group"

  dynamic "ingress" {
    for_each = local.private_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.from_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = ingress.value.security_groups
      self             = false
    }
  }

  dynamic "egress" {
    for_each = var.private_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.from_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      prefix_list_ids  = []
      security_groups  = egress.value.security_groups
      self             = false
    }
  }

  tags = merge({
    Name = "${local.prefix}_private_sg"
  }, var.tags)
}
