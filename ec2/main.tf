locals {
  volumesLen = length(var.volumes)
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_iam_role" {
  name               = var.instance_profile_name
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  dynamic "inline_policy" {
    for_each = var.machine_iam_policies

    content {
        name = lookup(inline_policy.value, "name", null)

        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Action   = lookup(inline_policy.value, "action", null)
              Effect   = lookup(inline_policy.value, "effect", null)
              Resource = lookup(inline_policy.value, "resource", null)
            },
          ]
        })
    }
  }
}

resource "aws_security_group" "ec2_security_group" {
  count       = var.create_sg ? 1 : 0
  name        = var.sg_name
  description = "EC2 SG"
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
    }
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_iam_role.name
}

resource "aws_instance" "ec2_instance" {

  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  vpc_security_group_ids      = concat([aws_security_group.ec2_security_group.id], var.security_groups_ids)
  key_name                    = var.key_pair
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination

  root_block_device {
    volume_size           = lookup(var.root_block_device, "volume_size", null)
    volume_type           = lookup(var.root_block_device, "volume_type", null)
    delete_on_termination = lookup(var.root_block_device, "delete_on_termination", null)
    kms_key_id            = lookup(var.root_block_device, "kms_key_id", null)
    device_name           = lookup(var.root_block_device, "device_name", null)
    encrypted             = lookup(var.root_block_device, "encrypted", null)
    iops                  = lookup(var.root_block_device, "iops", null)
    tags                  = lookup(var.root_block_device, "tags", null)
  }
  
  tags = merge(
    {
      "Name" = var.instance_name
    },
    var.common_tags
  )


  user_data = var.is_linux ? var.script : <<EOF
    <powershell>
    $len=${local.volumesLen}
    $csvValue="${var.disks_list}"
    if ($csvValue)
    {
      if( $csvValue.Contains("|") ) {
        $filename = "$env:TEMP\input.csv"
        $result= $csvValue.split('|')  
        $result | out-file $filename 
        $disks =  Import-Csv $filename -Header "Disk", "Letter", "Label"
      
        for ($num = 0 ; $num -lt $len; $num++) {  
          $letter =  $disks.letter.get($num)
          $diskNum =  $disks.disk.get($num)
          $diskLabel = $disks.label.get($num)
          $text="select disk $diskNum `n attributes disk clear readonly `n convert mbr `n create partition primary `n format quick fs=ntfs label=$diskLabel `n assign letter=$letter"
          $text  |ForEach-Object {$_ -Replace 'Warning', 'Caution'} |
              Set-Content -Path $env:TEMP\disk$diskNum.txt
        diskpart /s  $env:TEMP\disk$diskNum.txt
          }

      }else {
        $filename = "$env:TEMP\input.csv"
        $csvValue | out-file $filename  
        $disks =  Import-Csv $filename -Header "Disk", "Letter", "Label" 
        
        for ($num = 0 ; $num -lt $len; $num++) {  
          $letter =  $disks.letter
          $diskNum =  $disks.disk
          $diskLabel = $disks.label
          $text="select disk $diskNum `n attributes disk clear readonly `n convert mbr `n create partition primary `n format quick fs=ntfs label=$diskLabel `n assign letter=$letter"
          $text  |ForEach-Object {$_ -Replace 'Warning', 'Caution'} |
              Set-Content -Path $env:TEMP\disk$diskNum.txt
        diskpart /s  $env:TEMP\disk$diskNum.txt
          } 
      }
    }
    ${var.script}
    
    </powershell>
  EOF 
  lifecycle {
    ignore_changes = [ami, tags, user_data, root_block_device, iam_instance_profile]

  }
}

resource "aws_ebs_volume" "volume" {
  count             = length(var.volumes)
  availability_zone = aws_instance.ec2_instance.availability_zone
  size              = var.volumes[count.index].volume_size
  type              = var.volumes[count.index].volume_type
  iops              = var.volumes[count.index].iops
  kms_key_id        = var.volumes[count.index].kms_key_id
  tags              = var.volumes[count.index].tags

}

resource "aws_volume_attachment" "wsfc_node1_volume1_attachment" {
  count       = length(var.volumes)
  device_name = var.volumes[count.index].device_name
  volume_id   = aws_ebs_volume.volume[count.index].id
  instance_id = aws_instance.ec2_instance.id
}

resource "aws_network_interface" "networks" {
  count           = length(var.networks)
  subnet_id       = var.networks[count.index].subnet_id
  private_ips     = var.networks[count.index].private_ips
  security_groups = var.networks[count.index].security_groups

  attachment {
    instance     = aws_instance.ec2_instance.id
    device_index = var.networks[count.index].device_index
  }
}