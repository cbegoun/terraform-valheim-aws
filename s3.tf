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

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.web_app_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.web_app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.web_app_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.web_app_bucket.bucket
  key    = "index.html"
  source = "index.html"
}
