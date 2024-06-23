provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-00e89f3f4910f40a1"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "fanatik-unique-bucket"

  # Dočasně odstraněno prevent_destroy
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MyPolicy"
    Statement = [
      {
        Sid       = "PublicReadForGetBucketObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

output "website_url" {
  value       = aws_s3_bucket_website_configuration.s3_bucket_website.website_endpoint
  description = "URL for website hosted on S3"
}

output "s3_bucket_secure_url" {
  value       = "https://${aws_s3_bucket.s3_bucket.bucket}.s3.amazonaws.com"
  description = "Name of S3 bucket to hold website content"
}