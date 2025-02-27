resource "aws_route53_zone" "valheim" {
  name = "raeon.tech"
}

resource "aws_route53_record" "valheim" {
  zone_id = aws_route53_zone.valheim.zone_id
  name    = "valheim.raeon.tech"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.valheim.public_ip]
}