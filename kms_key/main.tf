# Creates/manages KMS CMK#####################
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "generic_cmk" {
  description = var.description
  tags        = merge(var.common_tags)
  #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#is_enabled
  is_enabled = var.is_enabled
  ###https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#customer_master_key_spec
  customer_master_key_spec = var.key_spec
  ##https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#enable_key_rotation
  enable_key_rotation = var.rotation_enabled
  ##https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#policy
  ##Note: Note: All KMS keys must have a key policy. If a key policy is not specified, 
  ##AWS gives the KMS key a default key policy that gives all principals in the owning account unlimited access to all KMS operations for the key. 
  ##This default key policy effectively delegates all access control to IAM policies and KMS grants.

  policy = data.aws_iam_policy_document.kms_policy.json
}
# Add an kms Key alias to the key
resource "aws_kms_alias" "generic_cmk_alias" {
  name          = "alias/${var.environment}-${var.aws_service}-key"
  target_key_id = aws_kms_key.generic_cmk.key_id
}

#####################################################################
#####Create KMS CMK key policy to control access to key##########
######https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document

data "aws_iam_policy_document" "kms_policy" {

  statement {
    actions = ["kms:*"]

    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = var.extra_policies

    content {
      sid       = lookup(statement.value, "sid", null)
      effect    = lookup(statement.value, "effect", null)
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", null)

      principals {
        identifiers = lookup(lookup(statement.value, "principals", null), "identifiers", null)
        type        = lookup(lookup(statement.value, "principals", null), "type", null)
      }
    }
  }

}
########Exposing KMS key arn as ssm parameter #####################
resource "aws_ssm_parameter" "kms_key_arn" {
  name        = "/${var.environment}/kmskey/${var.aws_service}/arn"
  tags        = merge(var.common_tags)
  description = "kms key arn"
  type        = "String"
  value       = aws_kms_key.generic_cmk.arn
}
#########################################################
