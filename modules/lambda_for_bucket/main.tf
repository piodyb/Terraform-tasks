
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

data "archive_file" "zipit" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "func" {
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.zipit.output_base64sha256
  function_name    = "lambda_function"
  role             = var.iam_for_lambda_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "welcomebucketgogogo123"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:Put"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_policy" "allow_access_from_iam_account" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.allow_access_from_iam_account.json
}

data "aws_iam_policy_document" "allow_access_from_iam_account" {
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
      "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
    ]
  }
}
