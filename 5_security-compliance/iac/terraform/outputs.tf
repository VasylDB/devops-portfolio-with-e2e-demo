output "public_bucket_name" {
  value = aws_s3_bucket.public_assets.bucket
}
output "private_bucket_name" {
  value = aws_s3_bucket.private_data.bucket
}
