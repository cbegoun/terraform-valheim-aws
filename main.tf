module "main" {
  source  = "app.terraform.io/terraform_cbegoun/valheim-module/aws"
  version = "1.5.0"

  admins                  = var.admins
  aws_region              = var.aws_region
  domain                  = var.domain
  instance_type           = var.instance_type
  purpose                 = var.purpose
  s3_lifecycle_expiration = var.s3_lifecycle_expiration
  server_name             = var.server_name
  server_password         = var.server_password
  sns_email               = var.sns_email
  unique_id               = var.unique_id
  world_name              = var.world_name
}


