resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({ Name = var.vpc_name }, var.common_tags)
}

#CREATING A INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = var.internet_gateway_name }, var.common_tags)
}

#PUBLIC SUBNET FROM A LIST
resource "aws_subnet" "public_subnets" {
  count                   = length(var.vpc_public_subnet_cidr)
  availability_zone       = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block              = element(var.vpc_public_subnet_cidr, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge({ Name = "${var.public_subnets_name}_${count.index + 1}" }, var.common_tags)
}

#CREATING A PUBLIC ROUTES
resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({ Name = var.public_subnet_routes_name }, var.common_tags)
}

#ASSOCIATE/LINK PUBLIC_ROUTE WITH PUBLIC_SUBNETS LIST
resource "aws_route_table_association" "public_association" {
  count          = length(var.vpc_public_subnet_cidr)
  route_table_id = aws_route_table.public_routes.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}

#CREATING PRIVATE SUBNETS FROM A LIST
resource "aws_subnet" "private_subnets" {
  count             = length(var.vpc_private_subnets)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block        = element(var.vpc_private_subnets, count.index)
  vpc_id            = aws_vpc.vpc.id


  tags = merge({ Name = "${var.private_subnet_name}_${count.index + 1}" }, var.common_tags)
}

#CREATING EIP NAT_GATEWAY FOR NAT_GATEWAY REDUNDANCY
resource "aws_eip" "eip_ngw" {
  count = var.total_nat_gateway_required
  tags  = merge({ Name = "${var.eip_for_nat_gateway_name}_${count.index + 1}" }, var.common_tags)
}

#CREATING NAT GATEWAYS IN PUBLIC_SUBNETS, EACH NAT_GATEWAY WILL BE DIFFERENT AZ FOR REDUNDANCY.
resource "aws_nat_gateway" "ngw" {
  count         = var.total_nat_gateway_required
  allocation_id = element(aws_eip.eip_ngw.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = merge({ Name = "${var.nat_gateway_name}_${count.index + 1}" }, var.common_tags)
}

#CREATING A PRIAVTE ROUTE_TABLE FOR PRIVATE_SUBNETS
resource "aws_route_table" "private_routes" {
  count  = length(aws_nat_gateway.ngw)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = var.private_route_cidr
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  tags = merge({ Name = "${var.private_route_table_name}_${count.index + 1}" }, var.common_tags)
}

#ASSOCIATE/LINK PRIVATE_ROUTES WITH PRIVATE_SUBNETS
resource "aws_route_table_association" "private_routes_linking" {
  count          = length(var.vpc_private_adb_subnet_cidr)
  route_table_id = element(aws_route_table.private_routes.*.id, count.index)
  subnet_id      = element(aws_subnet.private_subnets_adb.*.id, count.index)
}