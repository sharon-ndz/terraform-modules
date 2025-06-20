data "aws_caller_identity" "current" {}

resource "aws_lb" "this" {
  name                             = var.name
  load_balancer_type               = var.load_balancer_type
  internal                         = var.internal
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = lookup(subnet_mapping.value, "allocation_id", null)
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
    }
  }

 # access_logs {
   # enabled = true
  #  bucket  = var.access_logs_bucket
 #   prefix  = "${var.environment}/nlb"
#  }


  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = var.target_port
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tg"
    }
  )
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.target_ips)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.target_ips[count.index]
  port             = var.target_port
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.target_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
