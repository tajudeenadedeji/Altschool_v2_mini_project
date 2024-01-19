# output load balancer dns name
output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}

output "target_group_attach" {
  value = aws_lb_target_group_attachment.target_group_attachment
}


