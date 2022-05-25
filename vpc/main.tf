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
  count = length(var.public_subnets["cidrs_blocks"])

  vpc_id                    = aws_vpc.vpc.id
  availability_zone         = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block                = element(var.public_subnets["cidrs_blocks"], count.index)
  map_public_ip_on_launch   = lookup(var.public_subnets, "map_public_ip_on_launch", true)

  tags = merge({ Name = "${lookup(var.public_subnets, "subnets_name_prefix", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-subnet" }, var.common_tags)
}

#CREATING A PUBLIC ROUTES
resource "aws_route_table" "public_routes" {
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  dynamic "route" {
    for_each = lookup(var.public_subnets, "routes", [])
    content {
      cidr_block                = lookup(each.value, "cidr_block", "")
      egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", "")
      gateway_id                = lookup(each.value, "gateway_id", "")
      instance_id               = lookup(each.value, "instance_id", "")
      ipv6_cidr_block           = lookup(each.value, "ipv6_cidr_block", "")
      local_gateway_id          = lookup(each.value, "local_gateway_id", "")
      nat_gateway_id            = lookup(each.value, "nat_gateway_id", "")
      network_interface_id      = lookup(each.value, "network_interface_id", "")
      transit_gateway_id        = lookup(each.value, "transit_gateway_id", "")
      vpc_endpoint_id           = lookup(each.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", "")
    }
  }

  tags = merge({ Name = "${lookup(var.public_subnets, "route_table_name", "")}-rt" }, var.common_tags)
}

#ASSOCIATE/LINK PUBLIC_ROUTE WITH PUBLIC_SUBNETS LIST
resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnets["cidrs_blocks"])
  route_table_id = aws_route_table.public_routes.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}

#CREATING PRIVATE SUBNETS FROM A LIST
resource "aws_subnet" "private_lb_subnets" {
  count               = length(var.private_lb_subnets["cidrs_blocks"])

  vpc_id              = aws_vpc.vpc.id
  availability_zone   = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block          = element(var.private_lb_subnets["cidrs_blocks"], count.index)

  tags = merge({ Name = "${lookup(var.private_lb_subnets, "subnets_name_prefix", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-subnet" }, var.common_tags)
}

resource "aws_subnet" "private_app_subnets" {
  count               = length(var.private_app_subnets["cidrs_blocks"])

  vpc_id              = aws_vpc.vpc.id
  availability_zone   = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block          = element(var.private_app_subnets["cidrs_blocks"], count.index)

  tags = merge({ Name = "${lookup(var.private_app_subnets, "subnets_name_prefix", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-subnet" }, var.common_tags)
}

resource "aws_subnet" "private_data_subnets" {
  count               = length(var.private_data_subnets["cidrs_blocks"])

  vpc_id              = aws_vpc.vpc.id
  availability_zone   = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block          = element(var.private_data_subnets["cidrs_blocks"], count.index)

  tags = merge({ Name = "${lookup(var.private_data_subnets, "subnets_name_prefix", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-subnet" }, var.common_tags)
}

resource "aws_subnet" "private_services_subnets" {
  count               = length(var.private_services_subnets["cidrs_blocks"])

  vpc_id              = aws_vpc.vpc.id
  availability_zone   = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block          = element(var.private_services_subnets["cidrs_blocks"], count.index)

  tags = merge({ Name = "${lookup(var.private_services_subnets, "subnets_name_prefix", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-subnet" }, var.common_tags)
}

#CREATING EIP NAT_GATEWAY FOR NAT_GATEWAY REDUNDANCY
resource "aws_eip" "eip_ngw" {
  count = var.total_nat_gateway_required
  vpc   = true
  tags  = merge({ Name = "${var.eip_for_nat_gateway_name}-${count.index + 1}" }, var.common_tags)
}

#CREATING NAT GATEWAYS IN PUBLIC_SUBNETS, EACH NAT_GATEWAY WILL BE DIFFERENT AZ FOR REDUNDANCY.
resource "aws_nat_gateway" "ngw" {
  count         = var.total_nat_gateway_required
  allocation_id = element(aws_eip.eip_ngw.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = merge({ Name = "${var.nat_gateway_name}-${count.index + 1}" }, var.common_tags)
}

#CREATING A PRIVATE ROUTE_TABLE FOR PRIVATE_SUBNETS
resource "aws_route_table" "private_lb_subnets_rt" {
  count  = length(aws_nat_gateway.ngw)

  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  dynamic "route" {
    for_each = lookup(var.private_lb_subnets, "routes", [])
    content {
      cidr_block                = lookup(each.value, "cidr_block", "")
      egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", "")
      gateway_id                = lookup(each.value, "gateway_id", "")
      instance_id               = lookup(each.value, "instance_id", "")
      ipv6_cidr_block           = lookup(each.value, "ipv6_cidr_block", "")
      local_gateway_id          = lookup(each.value, "local_gateway_id", "")
      nat_gateway_id            = lookup(each.value, "nat_gateway_id", "")
      network_interface_id      = lookup(each.value, "network_interface_id", "")
      transit_gateway_id        = lookup(each.value, "transit_gateway_id", "")
      vpc_endpoint_id           = lookup(each.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", "")
    }
  }

  tags = merge({ Name = "${lookup(var.private_lb_subnets, "route_table_name", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-rt" }, var.common_tags)
}

resource "aws_route_table" "private_app_subnets_rt" {
  count  = length(aws_nat_gateway.ngw)

  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  dynamic "route" {
    for_each = lookup(var.private_app_subnets, "routes", [])
    content {
      cidr_block                = lookup(each.value, "cidr_block", "")
      egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", "")
      gateway_id                = lookup(each.value, "gateway_id", "")
      instance_id               = lookup(each.value, "instance_id", "")
      ipv6_cidr_block           = lookup(each.value, "ipv6_cidr_block", "")
      local_gateway_id          = lookup(each.value, "local_gateway_id", "")
      nat_gateway_id            = lookup(each.value, "nat_gateway_id", "")
      network_interface_id      = lookup(each.value, "network_interface_id", "")
      transit_gateway_id        = lookup(each.value, "transit_gateway_id", "")
      vpc_endpoint_id           = lookup(each.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", "")
    }
  }

  tags = merge({ Name = "${lookup(var.private_app_subnets, "route_table_name", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-rt" }, var.common_tags)
}

resource "aws_route_table" "private_data_subnets_rt" {
  count  = length(aws_nat_gateway.ngw)

  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = lookup(var.private_data_subnets, "is_public", "") ? aws_internet_gateway.igw.id : null
    nat_gateway_id = lookup(var.private_data_subnets, "is_public", "") ? null : element(aws_nat_gateway.ngw.*.id, count.index)
  }

  dynamic "route" {
    for_each = lookup(var.private_data_subnets, "routes", [])
    content {
      cidr_block                = lookup(each.value, "cidr_block", "")
      egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", "")
      gateway_id                = lookup(each.value, "gateway_id", "")
      instance_id               = lookup(each.value, "instance_id", "")
      ipv6_cidr_block           = lookup(each.value, "ipv6_cidr_block", "")
      local_gateway_id          = lookup(each.value, "local_gateway_id", "")
      nat_gateway_id            = lookup(each.value, "nat_gateway_id", "")
      network_interface_id      = lookup(each.value, "network_interface_id", "")
      transit_gateway_id        = lookup(each.value, "transit_gateway_id", "")
      vpc_endpoint_id           = lookup(each.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", "")
    }
  }

  tags = merge({ Name = "${lookup(var.private_data_subnets, "route_table_name", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-rt" }, var.common_tags)
}

resource "aws_route_table" "private_services_subnets_rt" {
  count  = length(aws_nat_gateway.ngw)

  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  dynamic "route" {
    for_each = lookup(var.private_services_subnets, "routes", [])
    content {
      cidr_block                = lookup(each.value, "cidr_block", "")
      egress_only_gateway_id    = lookup(each.value, "egress_only_gateway_id", "")
      gateway_id                = lookup(each.value, "gateway_id", "")
      instance_id               = lookup(each.value, "instance_id", "")
      ipv6_cidr_block           = lookup(each.value, "ipv6_cidr_block", "")
      local_gateway_id          = lookup(each.value, "local_gateway_id", "")
      nat_gateway_id            = lookup(each.value, "nat_gateway_id", "")
      network_interface_id      = lookup(each.value, "network_interface_id", "")
      transit_gateway_id        = lookup(each.value, "transit_gateway_id", "")
      vpc_endpoint_id           = lookup(each.value, "vpc_endpoint_id", "")
      vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", "")
    }
  }

  tags = merge({ Name = "${lookup(var.private_services_subnets, "route_table_name", "")}-az${substr(element(data.aws_availability_zones.azs.names, count.index), length(element(data.aws_availability_zones.azs.names, count.index)) - 1, length(element(data.aws_availability_zones.azs.names, count.index)))}-rt" }, var.common_tags)
}

#ASSOCIATE/LINK PRIVATE_ROUTES WITH PRIVATE_SUBNETS
resource "aws_route_table_association" "private_lb_subnets_rt_association" {
  count          = length(var.private_lb_subnets["cidrs_blocks"])
  route_table_id = element(aws_route_table.private_lb_subnets_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.private_lb_subnets.*.id, count.index)
}

resource "aws_route_table_association" "private_app_subnets_rt_association" {
  count          = length(var.private_app_subnets["cidrs_blocks"])
  route_table_id = element(aws_route_table.private_app_subnets_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.private_app_subnets.*.id, count.index)
}

resource "aws_route_table_association" "private_data_subnets_rt_association" {
  count          = length(var.private_data_subnets["cidrs_blocks"])
  route_table_id = element(aws_route_table.private_data_subnets_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.private_data_subnets.*.id, count.index)
}

resource "aws_route_table_association" "private_services_subnets_rt_association" {
  count          = length(var.private_services_subnets["cidrs_blocks"])
  route_table_id = element(aws_route_table.private_services_subnets_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.private_services_subnets.*.id, count.index)
}