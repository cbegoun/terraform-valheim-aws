output "hosted_zone_nameservers" {
  value       = aws_route53_zone.valheim_subdomain.name_servers
  description = "The Hosted Zone's NS records. Use this to delegate the zone from your parent zone."
}

output "private_key" {
  value     = tls_private_key.valheim_key.private_key_pem
  sensitive = true
}