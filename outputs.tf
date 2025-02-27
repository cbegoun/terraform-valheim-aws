output "nameservers" {
  value = aws_route53_zone.valheim.name_servers
}

output "web_page_address" {
  value = "http://valheim.raeon.tech/start"
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.valheim.private_key_pem
  filename          = "${path.module}/private_key.pem"
}

output "private_key_pem" {
  value     = tls_private_key.valheim.private_key_pem
  sensitive = true
}

output "private_key_path" {
  value = local_file.private_key.filename
}