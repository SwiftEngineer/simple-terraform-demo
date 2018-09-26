# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = "${var.bucket_name}"
  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT","POST"]
    allowed_origins = ["*"]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website_file" {
  # because of the version key, we are going to make sure not to
  # override existing versions of the app
  key = "index.html"

  # Bucket the code is gonna go into
  bucket = "${aws_s3_bucket.website.id}"
  source = "./code/index.html"

  content_type = "text/html"
}