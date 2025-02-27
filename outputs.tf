output "nameservers" {
  value = aws_route53_zone.valheim.name_servers
}

output "web_page_address" {
  value = "http://valheim.raeon.tech/start"
}

output "private_key_pem" {
  value     = tls_private_key.valheim.private_key_pem
}

output "public_key_openssh" {
  value = tls_private_key.valheim.public_key_openssh
}