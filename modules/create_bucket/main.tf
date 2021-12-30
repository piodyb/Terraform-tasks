locals {
  bucket_no_encryption = { for k, v in var.bucket_list : k => v if v.encryption != true }
  bucket_encryption    = { for k, v in var.bucket_list : k => v if v.encryption == true }
}

resource "aws_s3_bucket" "bucket" {
  for_each = local.bucket_no_encryption
  bucket   = each.value.name
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "bucket_encrypted" {
  for_each = local.bucket_encryption
  bucket   = each.value.name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket_policy" "allow_access_from_iam_lambda_no_encryption" {
  for_each = {for k, v in var.bucket_list : k => v}
  bucket   = each.value.name
  policy   = data.aws_iam_policy_document.allow_access_from_iam_lambda_no_encryption[each.key].json
}

data "aws_iam_policy_document" "allow_access_from_iam_lambda_no_encryption" {
  for_each = {for k, v in var.bucket_list : k => v}
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${var.iam_for_lambda_arn}"]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::${each.value.name}",
      "arn:aws:s3:::${each.value.name}/*"
    ]
  }
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket.bucket_encrypted]
}