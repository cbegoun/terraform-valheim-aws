resource "aws_eip" "valheim_eip" {
  vpc = true
}

resource "aws_route53_zone" "valheim_subdomain" {
  name = "valheim.${var.domain}"
}

resource "aws_route53_record" "subdomain_delegation" {
  zone_id = aws_route53_zone.valheim_subdomain.zone_id  # This is the Hosted Zone ID for raeon.tech
  name    = "valheim.${var.domain}"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.valheim_subdomain.name_servers

    lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_route53_record" "valheim_dns" {
  zone_id = aws_route53_zone.valheim_subdomain.zone_id
  name    = "valheim.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.valheim_eip.public_ip]

    lifecycle {
    ignore_changes = [records]
  }
}