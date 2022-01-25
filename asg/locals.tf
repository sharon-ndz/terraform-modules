locals {
  lt_name                 = coalesce(var.lt_name, var.name)
  launch_template         = var.create_lt ? aws_launch_template.this[0].name : var.launch_template
  launch_template_version = var.create_lt && var.lt_version == null ? aws_launch_template.this[0].latest_version : var.lt_version

  tags = distinct(concat(
    var.asg_tgs,
    [for k, v in var.tags :
      {
        key                 = k
        value               = v
        propagate_at_launch = var.propagate_common_tags_at_launch
      }
    ]
  ))
}