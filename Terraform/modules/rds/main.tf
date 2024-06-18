locals {
  prefix = "${var.project_name}_${var.project_env}"
}

# Create RDS subnet group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "${local.prefix}_db"
  subnet_ids  = var.private_subnets
  description = local.prefix

  tags = merge({
    Name = "${local.prefix}_sngr"
  }, var.tags)
}

resource "aws_db_parameter_group" "default" {
  name   = replace("${local.prefix}-pg", "_", "-")
  family = var.db_family

  dynamic "parameter" {
    for_each = var.rds_parameters
    content {
      apply_method = "immediate"
      name         = parameter.key
      value        = parameter.value
    }
  }
}

# Create RDS instance
resource "aws_db_instance" "database_instance" {
  engine         = var.db_engine
  engine_version = var.db_engine_version
  multi_az       = false
  identifier     = replace("${local.prefix}-db", "_", "-")
  # skip_final_snapshot  = true
  final_snapshot_identifier = replace("${local.prefix}-2024-001", "_", "-")
  snapshot_identifier       = try(var.snapshot_identifier, null)
  username                  = var.db_username
  password                  = var.db_password
  port                      = tonumber(var.db_port)
  instance_class            = var.db_instance_class
  parameter_group_name      = aws_db_parameter_group.default.name
  allocated_storage         = tonumber(var.db_allocated_storage)
  storage_type              = "gp2"
  db_subnet_group_name      = aws_db_subnet_group.database_subnet_group.id
  vpc_security_group_ids    = var.security_groups
  publicly_accessible       = false
  storage_encrypted         = true
  skip_final_snapshot       = true

  tags = merge({
    Name = "${local.prefix}_db"
  }, var.tags)
}
