output "waf_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.api_waf.arn
}

