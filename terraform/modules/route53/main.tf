resource "aws_route53_record" "this" {
  zone_id         = var.zone_id
  name            = var.record_name
  type            = var.record_type
  ttl             = var.alias_name == "" ? var.ttl : null
  allow_overwrite = true

  dynamic "alias" {
    for_each = var.alias_name != "" && var.alias_zone_id != "" ? [1] : []
    content {
      name                   = var.alias_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = true
    }
  }

  records = var.alias_name == "" ? var.records : null
}
