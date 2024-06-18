data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_tags = {
    ProjectName = var.project_name
    Env         = var.workspace
  }
  prefix       = "${var.project_name}_${var.workspace}"
  env          = var.workspace
  name         = var.project_name
  timezone     = "Asia/Tokyo"
  s3_origin_id = replace("${local.prefix}-frontend", "_", "-")
  is_not_prod  = coalesce(lower(local.env) != "prod", true, false)
}

# Create VPC
module "vpc" {
  source       = "../../modules/vpc"
  project_name = local.name
  project_env  = local.env
  tags         = local.common_tags

  vpc_cidr = var.vpc_cidr
}

# Create NAT gateway and assign eip
module "nat_eip" {
  source       = "../../modules/elastic-ip/for-nat"
  project_name = local.name
  project_env  = local.env
  tags         = local.common_tags
}

module "nat_gateway" {
  source       = "../../modules/nat-gateway"
  project_name = local.name
  project_env  = local.env
  tags         = local.common_tags

  internet_gateway    = module.vpc.igw
  private_route_table = module.vpc.private_route
  public_subnet       = module.vpc.public_sn_az1

  eip = module.nat_eip.eip
}




resource "aws_instance" "dev_machine" {
  ami = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  key_name = "aws-key-pair"
  subnet_id     = module.vpc.public_sn_az1

  tags = {
    Environment = "dev"
    Name = "${var.name}-server"
  }
}


