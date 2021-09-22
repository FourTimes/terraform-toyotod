resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"
  tags = merge({ Name = var.bucket_name }, tomap(var.additional_tags))
}
