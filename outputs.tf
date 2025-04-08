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

output "valheim_server_name" {
  value       = var.server_name
  description = "Name of the Valheim server"
}

# Output the private key for SSH access
output "valheim_private_key" {
  value     = module.main.valheim.private_key_pem
  sensitive = true
}

# Optional: public IP for convenience
output "valheim_instance_ip" {
  value = module.main.valheim.public_ip
}