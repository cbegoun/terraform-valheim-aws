resource "aws_s3_bucket" "valheim_backup" {
  bucket = "valheim-backup-raeon-tech"
  acl    = "private"
  tags = {
    Name        = "valheim-backup"
    Environment = "Production"
  }
}
