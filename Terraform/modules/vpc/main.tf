locals {
  prefix = "${var.project_name}_${var.project_env}"
}

# List AZ
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = merge({
    Name = "${local.prefix}_vpc"
  }, var.tags)
}

# Create Interget gateway and attact to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.prefix}_igw"
  }, var.tags)
}

# Create subnets includes 2 public and 2 private
resource "aws_subnet" "public_sn_az1" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 6, 0)
  map_public_ip_on_launch = true

  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 0)
  assign_ipv6_address_on_creation = true

  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]

  tags = merge({
    Name = "${local.prefix}_public_sn_az1"
  }, var.tags)
}

resource "aws_subnet" "public_sn_az2" {
  vpc_id = aws_vpc.vpc.id

  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 6, 1)
  map_public_ip_on_launch = true

  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true

  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = merge(
    { Name = "${local.prefix}_public_sn_az2" },
    var.tags
  )
}

resource "aws_subnet" "private_sn_az1" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 6, 30)

  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 2)
  assign_ipv6_address_on_creation = true

  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]

  tags = merge({
    Name = "${local.prefix}_private_sn_az1"
  }, var.tags)
}

resource "aws_subnet" "private_sn_az2" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 6, 31)

  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 3)
  assign_ipv6_address_on_creation = true

  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = merge({
    Name = "${local.prefix}_private_sn_az2"
  }, var.tags)
}

# Create public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.prefix}_public_rt"
  }, var.tags)
}

resource "aws_route" "attach_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Associate public subnet to route table
resource "aws_route_table_association" "public_sn_az1_rt_association" {
  subnet_id      = aws_subnet.public_sn_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_sn_az2_rt_association" {
  subnet_id      = aws_subnet.public_sn_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${local.prefix}_private_rt"
  }, var.tags)
}

# Associate private subnet to route table
resource "aws_route_table_association" "private_sn_az1_rt_association" {
  subnet_id      = aws_subnet.private_sn_az1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_sn_az2_rt_association" {
  subnet_id      = aws_subnet.private_sn_az2.id
  route_table_id = aws_route_table.private_rt.id
}
