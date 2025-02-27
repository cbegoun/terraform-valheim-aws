output "nameservers" {
  value = aws_route53_zone.valheim.name_servers
}

output "web_page_address" {
  value = "http://valheim.raeon.tech/start"
}