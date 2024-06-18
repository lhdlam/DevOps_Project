locals {
  prefix = "${var.project_name}_${var.project_env}"
}

resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc.id

  name        = "${local.prefix}_alb_sg"
  description = "ALB security group"

  ingress = [
    {
      description      = "Accept request from internet"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Accept request from internet"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp",
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge({
    Name = "${local.prefix}_alb_sg"
  }, var.tags)
}

resource "aws_security_group" "jumpbox_sg" {
  vpc_id      = var.vpc.id
  name        = "${local.prefix}_jumpbox_sg"
  description = "Jumpbox security group"

  ingress = [
    {
      description      = "Accept ssh connection"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge({
    Name = "${local.prefix}_jumpbox_sg"
  }, var.tags)
}

resource "aws_security_group" "app_sg" {
  vpc_id      = var.vpc.id
  name        = "${local.prefix}_app_sg"
  description = "Application security group"

  egress = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge({
    Name = "${local.prefix}_app_sg"
  }, var.tags)
}

# Create security rule to set peering if vpc_peers is setted
resource "aws_security_group_rule" "allow_ssh_from_peering" {
  count             = length(var.vpc_peers)

  type              = "ingress"
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22

  security_group_id = aws_security_group.app_sg.id
  description       = "Allow ssh connection through ${var.vpc_peers[count.index].peer_connection_id}"
  cidr_blocks       = [ var.vpc_peers[count.index].cidr_block ]
}

resource "aws_security_group_rule" "allow_http_from_alb" {
  type              = "ingress"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80

  security_group_id = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  description       = "Accept request from ALB"
}

resource "aws_security_group" "db_sg" {
  vpc_id      = var.vpc.id
  name        = "${local.prefix}_db_sg"
  description = "Database (PostgreSQL) security group"

  egress = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge({
    Name = "${local.prefix}_db_sg"
  }, var.tags)
}

resource "aws_security_group_rule" "allow_connect_from_app" {
  type              = "ingress"
  from_port         = var.db_port
  protocol          = "tcp"
  to_port           = var.db_port

  security_group_id = aws_security_group.db_sg.id
  source_security_group_id = aws_security_group.app_sg.id
  description       = "Accept connect from App"
}

resource "aws_security_group_rule" "allow_connect_from_jumpbox" {
  count             = var.jumpbox_ip != null ? 1 : 0

  type              = "ingress"
  from_port         = var.db_port
  protocol          = "tcp"
  to_port           = var.db_port

  security_group_id = aws_security_group.db_sg.id
  cidr_blocks       = [ var.jumpbox_ip ]

  description       = "Accept connect from Jumpbox IP"
}
