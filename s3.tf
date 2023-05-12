resource "aws_s3_bucket" "configuration_bucket" {
  provider = aws.master_region
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.configuration_bucket.bucket
  key    = "index.html"
  source = "webconfig/index.html"
}

resource "aws_s3_object" "load_balancer_config" {
  bucket = aws_s3_bucket.configuration_bucket.bucket
  key    = "load_balancer"
  source = "webconfig/load_balancer"
}

resource "aws_s3_object" "static_config" {
  bucket = aws_s3_bucket.configuration_bucket.bucket
  key    = "static"
  source = "webconfig/static"
}