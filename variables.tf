variable "admins" {
  type        = map(any)
  default     = { "default_valheim_user" = "", }
  description = "List of AWS users/Valheim server admins (use their SteamID)"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to create the Valheim server"
}

variable "domain" {
  type        = string
  default     = "raeon.tech"
  description = "Domain name used to create a static monitoring URL"
}

variable "instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "AWS EC2 instance type to run the server on (t3a.medium is the minimum size)"
}

variable "server_name" {
  type        = string
  description = "The server name"
}

variable "server_password" {
  type        = string
  description = "The server password"
}

variable "world_name" {
  type        = string
  description = "The Valheim world name"
}