resource "aws_s3_bucket" "valheim_backup" {
  bucket = "valheim-backup.${var.domain}"
  acl    = "private"
  tags = {
    Name        = "valheim-backup"
    Environment = "Production"
  }
}
