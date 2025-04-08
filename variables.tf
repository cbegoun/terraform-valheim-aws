variable "admins" {
  type        = map(any)
  default     = { "default_valheim_user" = "", }
  description = "List of AWS users/Valheim server admins (use their SteamID)"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "domain" {
  type        = string
  default     = "raeon.tech"
  description = "Domain name used to create a static monitoring URL"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "AWS EC2 instance type to run the server on (t3a.medium is the minimum size)"
}

variable "valheim_server_name" {
  description = "Name of the Valheim server"
  type        = string
  default     = "Raeon's Valheim Server"
}

variable "valheim_world_name" {
  description = "Name of the Valheim world"
  type        = string
  default     = "Midgard_0425"
}

variable "valheim_password" {
  description = "Password for the Valheim server"
  type        = string
  sensitive   = true
}

variable "your_ip_cidr" {
  description = "Your IP address with /32 suffix for RDP"
  type        = string
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair"
  type        = string
  default     = "valheim-keypair"
}