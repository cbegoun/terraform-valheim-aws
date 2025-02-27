output "nameservers" {
  value = aws_route53_zone.valheim.name_servers
}

output "web_page_address" {
  value = "http://valheim.raeon.tech/start"
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.example.private_key_pem
  filename          = "${path.module}/private_key.pem"
}

output "private_key_file" {
  value     = local_file.private_key.filename
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key.valheim.public_key_openssh
}

