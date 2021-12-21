########Create S3 Bucket for VPC Flow Logs###################
resource "aws_s3_bucket" "this" {

  bucket = var.bucket_name
  tags   = merge({ Name = var.bucket_name }, var.common_tags)
  acl = var.acl
  force_destroy = var.force_destroy_option

  versioning {
    enabled = var.enable_bucket_versioning
  }

  lifecycle_rule {
    id      = "RuleForObjects"
    enabled = var.life_cycle_option

    transition {
      days          = var.transition_in_days
      storage_class = var.life_cycle_storage_class
    }

    dynamic "expiration" {
      for_each = var.expiration_in_days != "0" ? [1] : []
      content {
        days = var.expiration_in_days
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

data "aws_iam_policy_document" "this" {
  count = var.create_bucket_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.bucket_policy
    
    content {
        sid = lookup(statement.value, "sid", null)

        principals {
          type        = lookup(lookup(statement.value, "principals", null),"type", null)
          identifiers = lookup(lookup(statement.value, "principals", null),"identifiers", null)
        }

        effect    = lookup(statement.value, "effect", null)
        actions   = lookup(statement.value, "actions", null)
        resources = lookup(statement.value, "resources", null)


        dynamic "condition" {
          for_each = statement.value.condition == null ? [] : statement.value.condition == {} ? [] : [1]

          content {
            test     = lookup(lookup(statement.value, "condition", null),"test", null)
            variable = lookup(lookup(statement.value, "condition", null),"variable", null)
            values   = lookup(lookup(statement.value, "condition", null),"values", null)
          }
        }
    }
  }
}

##########################################
############# Blcok Public access for bucket #############
resource "aws_s3_bucket_public_access_block" "S3PublicAccess" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}