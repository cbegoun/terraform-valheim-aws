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

variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "github_token" {
  type        = string
  description = "GitHub token with repo access"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name"
}

variable "api_id" {
  type        = string
  description = "API Gateway ID"
}