variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "Region to deploy the Valheim server in"
}

variable "domain_name" {
  type        = string
  default     = "raeon.tech"
  description = "Your domain to create a Hosted Zone for (for 'example.com' the server will be reachable under valheim.example.com)"
}

variable "project_name" {
  type    = string
  default = "valheim"
}