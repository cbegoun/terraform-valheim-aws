resource "aws_s3_bucket" "valheim_backup" {
  bucket = "valheim-backup.${var.domain}"
  acl    = "private"
  tags = {
    Name        = "valheim-backup"
    Environment = "Production"
  }
}


##web app bucket
resource "aws_s3_bucket" "web_app_bucket" {
  bucket = "valheim.raeon.tech-webapp"  # Replace with your desired bucket name
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.web_app_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
}
