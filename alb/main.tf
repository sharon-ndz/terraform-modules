resource "aws_security_group" "alb_security_group" {
  count       = var.create_sg ? 1 : 0
  name        = var.sg_name
  description = "EC2 SG for ${var.sg_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_roles
    content {
        description         = lookup(ingress.value, "description", null)
        from_port           = lookup(ingress.value, "from_port", null)
        to_port             = lookup(ingress.value, "to_port", null)
        protocol            = lookup(ingress.value, "protocol", null)
        cidr_blocks         = lookup(ingress.value, "cidr_blocks", null)
        ipv6_cidr_blocks    = lookup(ingress.value, "ipv6_cidr_blocks", null)
        security_groups     = lookup(ingress.value, "security_groups", null)
        self                = lookup(ingress.value, "self", null)
    }
  }

  dynamic "egress" {
    for_each = var.egress_roles
    content {
        description         = lookup(egress.value, "description", null)
        from_port           = lookup(egress.value, "from_port", null)
        to_port             = lookup(egress.value, "to_port", null)
        protocol            = lookup(egress.value, "protocol", null)
        cidr_blocks         = lookup(egress.value, "cidr_blocks", null)
        ipv6_cidr_blocks    = lookup(egress.value, "ipv6_cidr_blocks", null)
        security_groups     = lookup(egress.value, "security_groups", null)
        self                = lookup(egress.value, "self", null)
    }
  }
}

resource "aws_lb" "this" {
  count = var.create_lb ? 1 : 0

  name                             = var.name
  name_prefix                      = var.name_prefix

  load_balancer_type               = var.load_balancer_type
  internal                         = var.internal
  security_groups                  = var.create_sg ? concat([aws_security_group.ec2_security_group[0].id], var.security_groups) : var.security_groups
  subnets                          = var.subnets

  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type
  drop_invalid_header_fields       = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = length(keys(var.access_logs)) == 0 ? [] : [var.access_logs]

    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping

    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = lookup(subnet_mapping.value, "allocation_id", null)
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
    }
  }

  tags = merge(
    var.tags,
    var.lb_tags,
    {
      Name = var.name != null ? var.name : var.name_prefix
    },
  )

  timeouts {
    create = var.load_balancer_create_timeout
    update = var.load_balancer_update_timeout
    delete = var.load_balancer_delete_timeout
  }
}

resource "aws_route53_record" "internal_resolving" {
  count   = var.create_zone_record ? 1 : 0

  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.record_ttl
  records = [concat(aws_lb.this.*.dns_name, [""])[0]]
}