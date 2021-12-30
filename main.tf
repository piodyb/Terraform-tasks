provider "aws" {
  region     = "us-west-2"
}

module "iam_for_lambda" {
  source = "./modules/iam_for_lambda"
}

module "create_bucket" {
    source = "./modules/create_bucket"

    iam_for_lambda_arn = module.iam_for_lambda.iam_for_lambda_arn
    bucket_list = var.buckets
}

module "lambda_for_bucket" {
    source = "./modules/lambda_for_bucket"

    iam_for_lambda_arn = module.iam_for_lambda.iam_for_lambda_arn
}