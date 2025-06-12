output "alb_arn" {
  value = aws_lb.this.arn
}
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
output "dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb.id
}