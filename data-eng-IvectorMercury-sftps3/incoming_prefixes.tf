resource "aws_s3_object" "incoming_prefix" {
  for_each = toset(local.file_rename_roots)

  bucket       = data.aws_s3_bucket.ivector.id
  key          = "${each.value}/"
  content      = ""
  content_type = "application/x-directory"
}
