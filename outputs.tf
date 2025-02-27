output "monitoring_url" {
  value       = module.main.monitoring_url
  description = "URL to monitor the Valheim Server"
}

output "bucket_id" {
  value       = module.main.bucket_id
  description = "The S3 bucket name"
}

output "instance_id" {
  value       = module.main.instance_id
  description = "The EC2 instance ID"
}
output "hosted_zone_nameservers" {
  value       = aws_route53_zone.minecraft_ondemand_route53_zone.name_servers
  description = "The Hosted Zone's NS records. Use this to delegate the zone from your parent zone."
}

output "valheim_server_name" {
  value       = var.server_name
  description = "Name of the Valheim server"
}