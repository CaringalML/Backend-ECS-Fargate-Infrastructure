# Create A record for server subdomain
resource "aws_route53_record" "server" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "server.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
