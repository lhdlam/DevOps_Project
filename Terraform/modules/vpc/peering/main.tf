locals {
  prefix = "${var.project_name}_${var.project_env}"
}

# Create peering connection
resource "aws_vpc_peering_connection" "this" {
  count       = length(var.vpc_peers)
  vpc_id      = var.vpc.id
  peer_vpc_id = var.vpc_peers[count.index].vpc_id
  peer_region = var.vpc_peers[count.index].region

  lifecycle {
    ignore_changes = [ auto_accept ]
  }

  tags = merge({
    Name = "${local.prefix}_peering"
  }, var.tags)
}

# Create route
resource "aws_route" "this" {
  count                     = length(var.vpc_peers)
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.vpc_peers[count.index].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[count.index].id

  depends_on = [ aws_vpc_peering_connection.this ]
}
