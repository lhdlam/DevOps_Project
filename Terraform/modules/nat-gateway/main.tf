locals {
  prefix = "${var.project_name}_${var.project_env}"
}

# Creae nat gateway and associate to subnets
resource "aws_nat_gateway" "public_nat" {
  subnet_id     = var.public_subnet.id
  allocation_id = var.eip.id

  depends_on = [var.internet_gateway]

  tags = merge({
    Name = "${local.prefix}_public_az1_nat"
  }, var.tags)
}

resource "aws_route" "aws_route" {
  route_table_id         = var.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.public_nat.id
  destination_cidr_block = "0.0.0.0/0"
}
